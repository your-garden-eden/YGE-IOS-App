// Path: Your-Garden-Eden-IOS/Core/Service/CartAPIManager.swift
// VERSION 3.4 (FINAL - Synchronized with AppModels v2.9 Initializer)

import Foundation

@MainActor
final class CartAPIManager: ObservableObject {
    struct State {
        var items: [Item] = []
        var totals: Totals? = nil
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var updatingItemKey: String? = nil
        var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
    }

    @Published private(set) var state = State()

    static let shared = CartAPIManager()
    private let session: URLSession

    private init() {
        self.session = URLSession(configuration: .default)
        print("✅ CartAPIManager initialized.")
    }

    func initializeAndFetchCart() async {
        await getCart(showLoadingIndicator: true)
    }

    // MARK: - Public Cart Actions
    func getCart(showLoadingIndicator: Bool = false) async {
        await performCartAction(isLoading: showLoadingIndicator) {
            try await self.performRequest(path: "cart", httpMethod: "GET")
        }
    }
    
    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async {
        await performCartAction(isLoading: true) {
            
            let idToAdd: Int
            if let variationId = variationId {
                idToAdd = variationId
            } else {
                idToAdd = productId
            }
            
            let body: [String: Any] = [
                "id": idToAdd,
                "quantity": quantity
            ]
            
            return try await self.performRequest(path: "cart/add-item", httpMethod: "POST", body: body)
        }
    }
    
    func updateQuantity(for item: Item, newQuantity: Int) async {
        await performCartAction(updatingItemKey: item.key) {
            try await self.performRequest(path: "cart/update-item", httpMethod: "POST", body: ["key": item.key, "quantity": newQuantity])
        }
    }
    
    func removeItem(_ item: Item) async {
        await performCartAction(updatingItemKey: item.key) {
            try await self.performRequest(path: "cart/remove-item", httpMethod: "POST", body: ["key": item.key])
        }
    }
    
    // MARK: - Private Core Logic
    private func performCartAction(isLoading: Bool = false, updatingItemKey: String? = nil, _ action: @escaping () async throws -> WooCommerceStoreCart?) async {
        state.isLoading = isLoading
        state.updatingItemKey = updatingItemKey
        state.errorMessage = nil
        
        do {
            if let newCart = try await action() {
                state.items = newCart.safeItems
                state.totals = newCart.totals
            }
            state.errorMessage = nil
        } catch {
            let apiError = error as? WooCommerceAPIError ?? .underlying(error)
            state.errorMessage = apiError.localizedDescription
            print("🔴 CartAPIManager Error: \(error.localizedDescription)")
        }
        
        state.isLoading = false
        state.updatingItemKey = nil
    }
    
    @discardableResult
    private func performRequest(path: String, httpMethod: String, body: [String: Any]? = nil) async throws -> WooCommerceStoreCart? {
        guard let url = URL(string: AppConfig.WooCommerce.storeApiBaseURL + "v1/" + path) else {
            throw WooCommerceAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let cartToken = KeychainHelper.getCartToken() {
            request.setValue(cartToken, forHTTPHeaderField: "Cart-Token")
            print("ℹ️ Cart Token attached to request for \(path).")
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0))
        }
        
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "cart-token") {
            try? KeychainHelper.saveCartToken(newCartToken)
            print("✅ New Cart Token received and saved.")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let rawError = String(data: data, encoding: .utf8) {
                print("💡 SERVER ERROR RESPONSE (raw): \(rawError)")
            }
            let err = try? JSONDecoder().decode(WooCommerceStoreErrorResponse.self, from: data)
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
        
        if data.isEmpty {
            print("✅ Request to \(path) successful, but response body is empty. Assuming empty cart.")
            // ===================================================================
            // **FINALE KORREKTUR:**
            // Ruft den neuen, einfachen Initializer auf, der in AppModels.swift
            // Version 2.9 definiert wurde.
            // ===================================================================
            return WooCommerceStoreCart()
        }
        
        do {
            let decoder = JSONDecoder()
            // ÄNDERUNG: Wir verwenden jetzt die Standard-Strategie, da unsere Modelle
            // die snake_case Namen direkt verwenden (z.B. total_price).
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WooCommerceStoreCart.self, from: data)
        } catch let decodingError {
            print("🔴 DECODING FAILED for path: \(path). Error: \(decodingError.localizedDescription)")
            if let rawResponseString = String(data: data, encoding: .utf8) {
                print("💡 RAW SERVER RESPONSE PAYLOAD:\n---\n\(rawResponseString)\n---")
            }
            throw decodingError
        }
    }
}
