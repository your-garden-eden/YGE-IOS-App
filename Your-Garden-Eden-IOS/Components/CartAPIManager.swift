// Core/Networking/CartAPIManager.swift

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
    private var initializationTask: Task<Void, Never>?

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        print("🛒 CartAPIManager initialized.")
        
        self.initializationTask = Task {
            // Nur den Gast-Token laden, wenn der User NICHT eingeloggt ist.
            if AuthManager.shared.getAuthToken() == nil {
                self.cartToken = try? KeychainHelper.getCartToken()
            }
            _ = await getCart()
            self.initializationTask = nil
        }
    }

    private func ensureTokensAreAvailable() async throws {
        if let task = initializationTask { await task.value }
        
        // Wenn der User eingeloggt ist, reicht der JWT-Token.
        if AuthManager.shared.getAuthToken() != nil { return }
        
        // Ansonsten für Gäste sicherstellen, dass wir einen Token haben.
        if cartToken == nil && cartNonce == nil {
            print("🛒 CartAPIManager: Both Cart-Token and Nonce are missing for GUEST. Actively fetching...")
            _ = await getCart()
        }
        guard cartToken != nil || cartNonce != nil else {
            let error = WooCommerceAPIError.internalError("Could not obtain any GUEST authentication token (Cart-Token or Nonce).")
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Public API
    
    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async throws {
        try await ensureTokensAreAvailable()
        
        var body: [String: Any] = [
            "id": productId,
            "quantity": quantity
        ]
        
        // Wichtige Korrektur: Die Store-API bevorzugt 'variation_id' für variable Produkte
        if let variationId = variationId, variationId > 0 {
             body = ["id": variationId, "quantity": quantity]
        }
        
        try await performCartRequest(path: "cart/add-item", httpMethod: "POST", body: body)
    }
    
    func updateItemQuantity(itemKey: String, quantity: Int) async throws {
        try await ensureTokensAreAvailable()
        let body = ["quantity": quantity]
        try await performCartRequest(path: "cart/items/\(itemKey)", httpMethod: "PUT", body: body)
    }
    
    func removeItem(itemKey: String) async throws {
        try await ensureTokensAreAvailable()
        try await performCartRequest(path: "cart/items/\(itemKey)", httpMethod: "DELETE")
    }
    
    func clearCart() async throws {
        try await ensureTokensAreAvailable()
        try await performCartRequest(path: "cart/items", httpMethod: "DELETE")
    }
    
    @discardableResult
    func getCart() async -> WooCommerceStoreCart? {
        do { return try await performCartRequest(path: "cart", httpMethod: "GET") }
        catch { return nil }
    }
    
    // MARK: - Private Request Logic
    
    @discardableResult
    private func performCartRequest(path: String, httpMethod: String, body: [String: Any]) async throws -> WooCommerceStoreCart? {
        let requestBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        return try await performBaseRequest(path: path, httpMethod: httpMethod, body: requestBody)
    }
    
    @discardableResult
    private func performCartRequest(path: String, httpMethod: String) async throws -> WooCommerceStoreCart? {
        return try await performBaseRequest(path: path, httpMethod: httpMethod, body: nil)
    }
    
    @discardableResult
    private func performBaseRequest(path: String, httpMethod: String, body: Data?) async throws -> WooCommerceStoreCart? {
        isLoading = true; errorMessage = nil; defer { isLoading = false }
        
        var urlString = storeApiBaseURL + path
        if httpMethod == "GET" { urlString += "?_=\(Date().timeIntervalSince1970)" }
        
        guard let url = URL(string: urlString) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // --- *** DIE INTELLIGENTE TOKEN-LOGIK *** ---
        if let jwtToken = AuthManager.shared.getAuthToken() {
            // 1. BENUTZER IST EINGELOGGT: JWT-Token verwenden.
            print("🛒 CartAPIManager: Performing request as LOGGED-IN user.")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
            
            // Lokalen Gast-Token proaktiv löschen, um Konflikte zu vermeiden
            if self.cartToken != nil {
                self.cartToken = nil
                try? KeychainHelper.deleteCartToken()
            }
        } else {
            // 2. BENUTZER IST GAST: Gast-Token oder Nonce verwenden.
            print("🛒 CartAPIManager: Performing request as GUEST user.")
            if let token = self.cartToken {
                request.setValue(token, forHTTPHeaderField: "Cart-Token")
            }
            if let nonce = self.cartNonce {
                request.setValue(nonce, forHTTPHeaderField: "X-WC-Store-API-Nonce")
            }
        }
        
        if let body = body { request.httpBody = body }
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])) }

            if let newNonce = httpResponse.value(forHTTPHeaderField: "X-WC-Store-API-Nonce") {
                self.cartNonce = newNonce
            }
            
            // Den Gast-Token nur speichern, wenn der Benutzer NICHT eingeloggt ist.
            if AuthManager.shared.getAuthToken() == nil {
                if let newToken = httpResponse.value(forHTTPHeaderField: "Cart-Token"), newToken != self.cartToken {
                    self.cartToken = newToken
                    try KeychainHelper.saveCartToken(newToken)
                    print("🛒 CartAPIManager: New GUEST Cart-Token received and saved.")
                }
            }
            
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
