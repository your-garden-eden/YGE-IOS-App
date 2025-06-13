// Dateiname: Core/Managers/CartAPIManager.swift
import Foundation
import Combine

@MainActor
final class CartAPIManager: ObservableObject {
    
    static let shared = CartAPIManager()
    
    @Published private(set) var items: [Item] = []
    @Published private(set) var totals: Totals?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    var itemCount: Int { items.count }
    
    private let storeApiBaseURL = AppConfig.WooCommerce.storeApiBaseURL
    private var session: URLSession
    private var cartToken: String?
    private var cartNonce: String?

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        print("🛒 CartAPIManager initialized.")
        
        Task {
            if AuthManager.shared.getAuthToken() == nil {
                self.cartToken = try? KeychainHelper.getCartToken()
            }
            await getCart()
        }
    }

    // MARK: - Public API
    
    func updateQuantity(for item: Item, newQuantity: Int) async {
        guard item.quantity != newQuantity else { return }
        await performCartAction {
            let body = ["quantity": newQuantity]
            return try await self.performCartRequest(path: "cart/items/\(item.key)", httpMethod: "PUT", body: body)
        }
    }

    func removeItem(_ item: Item) async {
        await performCartAction {
            return try await self.performCartRequest(path: "cart/items/\(item.key)", httpMethod: "DELETE")
        }
    }
    
    func getCart() async {
        await performCartAction {
            return try await self.performCartRequest(path: "cart", httpMethod: "GET")
        }
    }
    
    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async {
        await performCartAction {
            var body: [String: Any]
            if let variationId = variationId, variationId > 0 { body = ["id": variationId, "quantity": quantity] }
            else { body = ["id": productId, "quantity": quantity] }
            return try await self.performCartRequest(path: "cart/add-item", httpMethod: "POST", body: body)
        }
    }
    
    // MARK: - State Management & Request Logic
    
    private func performCartAction(_ action: @escaping () async throws -> WooCommerceStoreCart?) async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let newCart = try await action()
            self.items = newCart?.safeItems ?? []
            self.totals = newCart?.totals
        } catch {
            let finalErrorMsg = (error as? KeychainError) != nil ? "Ein Sicherheitsproblem ist aufgetreten." : "Ein Warenkorb-Fehler ist aufgetreten."
            self.errorMessage = finalErrorMsg
            print("🔴 CartAPIManager Action Failed: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
    
    @discardableResult
    private func performCartRequest(path: String, httpMethod: String, body: [String: Any]? = nil) async throws -> WooCommerceStoreCart? {
        var requestBody: Data? = nil
        if let body = body { requestBody = try? JSONSerialization.data(withJSONObject: body, options: []) }
        
        var urlString = storeApiBaseURL + path
        if httpMethod == "GET" { urlString += "?_=\(Date().timeIntervalSince1970)" }
        
        guard let url = URL(string: urlString) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let jwtToken = AuthManager.shared.getAuthToken() {
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
            if self.cartToken != nil { self.cartToken = nil; try? KeychainHelper.deleteCartToken() }
        } else {
            if cartToken == nil && cartNonce == nil {
                let (_, headerResponse) = try await session.data(for: URLRequest(url: url))
                if let newNonce = (headerResponse as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-WC-Store-API-Nonce") { self.cartNonce = newNonce }
            }
            if let token = self.cartToken { request.setValue(token, forHTTPHeaderField: "Cart-Token") }
            if let nonce = self.cartNonce { request.setValue(nonce, forHTTPHeaderField: "X-WC-Store-API-Nonce") }
        }
        
        if let body = requestBody { request.httpBody = body }
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])) }
        
        if let newNonce = httpResponse.value(forHTTPHeaderField: "X-WC-Store-API-Nonce") { self.cartNonce = newNonce }
        
        if AuthManager.shared.getAuthToken() == nil {
            if let newToken = httpResponse.value(forHTTPHeaderField: "Cart-Token"), newToken != self.cartToken { self.cartToken = newToken; try KeychainHelper.saveCartToken(newToken) }
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"; print("🔴 CartAPIManager Request Error: Status \(httpResponse.statusCode). Body: \(errorBody)")
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: "Serverfehler: \(httpResponse.statusCode)", errorCode: nil)
        }
        
        if data.isEmpty { return nil }
        
        let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(WooCommerceStoreCart.self, from: data)
    }
}
