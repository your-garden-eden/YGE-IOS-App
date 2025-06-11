import Foundation
import Combine

@MainActor
final class CartAPIManager: ObservableObject {
    
    static let shared = CartAPIManager()
    
    @Published private(set) var currentCart: WooCommerceStoreCart?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    var itemCount: Int { currentCart?.safeItems.count ?? 0 }
    
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
            self.cartToken = try? KeychainHelper.getCartToken()
            // Der erste getCart-Aufruf holt uns die ALLERERSTE Nonce.
            _ = await getCart()
        }
    }

    // Die `refreshNonce`-Funktion wird nicht mehr benötigt.

    // MARK: - Public API
    func addItem(productId: Int, quantity: Int) async throws {
        let body = ["id": productId, "quantity": quantity]
        try await performCartRequest(path: "cart/add-item", httpMethod: "POST", body: body)
    }
    func updateItemQuantity(itemKey: String, quantity: Int) async throws {
        let body = ["quantity": quantity]
        try await performCartRequest(path: "cart/items/\(itemKey)", httpMethod: "PUT", body: body)
    }
    func removeItem(itemKey: String) async throws {
        try await performCartRequest(path: "cart/items/\(itemKey)", httpMethod: "DELETE")
    }
    func clearCart() async throws {
        try await performCartRequest(path: "cart/items", httpMethod: "DELETE")
    }
    
    @discardableResult
    func getCart() async -> WooCommerceStoreCart? {
        do { return try await performCartRequest(path: "cart", httpMethod: "GET") }
        catch { return nil }
    }
    
    // ... (performCartRequest bleibt gleich) ...
    @discardableResult
    private func performCartRequest<T: Encodable>(path: String, httpMethod: String, body: T) async throws -> WooCommerceStoreCart? {
        let requestBody = try? JSONEncoder().encode(body)
        return try await performBaseRequest(path: path, httpMethod: httpMethod, body: requestBody)
    }
    @discardableResult
    private func performCartRequest(path: String, httpMethod: String) async throws -> WooCommerceStoreCart? {
        return try await performBaseRequest(path: path, httpMethod: httpMethod, body: nil)
    }
    
    @discardableResult
    private func performBaseRequest(path: String, httpMethod: String, body: Data?) async throws -> WooCommerceStoreCart? {
        isLoading = true; errorMessage = nil; defer { isLoading = false }
        guard let url = URL(string: storeApiBaseURL + path) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = self.cartToken { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        
        // Nonce nur bei schreibenden Aktionen hinzufügen.
        if httpMethod != "GET" {
            if let nonce = self.cartNonce {
                request.setValue(nonce, forHTTPHeaderField: "X-WC-Store-API-Nonce")
            } else {
                print("⚠️ CartAPIManager: No Nonce available for first write-request. This might be okay if the first GET failed.")
            }
        }
        
        if let body = body { request.httpBody = body }
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])) }

            // Wir speichern IMMER die neueste Nonce, die uns der Server gibt.
            if let newNonce = httpResponse.value(forHTTPHeaderField: "X-WC-Store-API-Nonce") {
                self.cartNonce = newNonce
                print("🛒 CartAPIManager: Nonce received and stored: \(newNonce.prefix(8))...")
            }
            
            // ... (Rest der Funktion bleibt gleich) ...
            if let newToken = httpResponse.value(forHTTPHeaderField: "cart-token"), newToken != self.cartToken { self.cartToken = newToken; try KeychainHelper.saveCartToken(newToken); print("🛒 CartAPIManager: New cart-token received and saved.") }
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"; print("🔴 CartAPIManager Error: Status \(httpResponse.statusCode). Body: \(errorBody)")
                let apiError = WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: "Serverfehler: \(httpResponse.statusCode)", errorCode: nil); self.errorMessage = apiError.localizedDescription; throw apiError
            }
            if data.isEmpty { self.currentCart = nil; return nil }
            let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
            let updatedCart = try decoder.decode(WooCommerceStoreCart.self, from: data); self.currentCart = updatedCart; return updatedCart
        } catch {
            print("🔴 CartAPIManager: Failed to perform request for path '\(path)': \(error)"); if error is KeychainError { self.errorMessage = "Ein Sicherheitsproblem ist aufgetreten." } else if self.errorMessage == nil { self.errorMessage = "Ein Netzwerkfehler ist aufgetreten." }; throw error
        }
    }
}
