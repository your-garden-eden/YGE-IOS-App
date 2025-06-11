import Foundation
import Combine

@MainActor
final class CartAPIManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = CartAPIManager()
    
    // MARK: - Published Properties
    @Published private(set) var currentCart: WooCommerceStoreCart?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    var itemCount: Int {
        currentCart?.itemsCount ?? 0
    }
    
    // MARK: - Private Properties
    private let storeApiBaseURL = AppConfig.WooCommerce.storeApiBaseURL
    private var session: URLSession
    private var cartToken: String?
    private var initialLoadTask: Task<Void, Never>?
    
    // MARK: - Initializer
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        print("🛒 CartAPIManager initialized.")
        ensureTokensAndCartLoaded()
    }
    
    // MARK: - Public API (Core Cart Operations)

    func ensureTokensAndCartLoaded() {
        if initialLoadTask != nil { return }
        
        initialLoadTask = Task {
            defer { initialLoadTask = nil }
            do {
                self.cartToken = try KeychainHelper.getCartToken()
                print("🛒 CartAPIManager: Token from keychain: \(cartToken == nil ? "Not found" : "Found").")
                await getCart()
            } catch {
                errorMessage = "Fehler beim Laden des Warenkorb-Tokens: \(error.localizedDescription)"
                print("🔴 CartAPIManager: Failed to load token from keychain: \(error)")
            }
        }
    }
    
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
        do {
            return try await performCartRequest(path: "cart", httpMethod: "GET")
        } catch {
            return nil
        }
    }
    
    // MARK: - Private Core Logic

    /// **NEU: Zentraler Handler für Anfragen MIT Body (POST, PUT).**
    @discardableResult // KORREKTUR: Fügt das Attribut hinzu, um Warnungen zu unterdrücken.
    private func performCartRequest<T: Encodable>(path: String, httpMethod: String, body: T) async throws -> WooCommerceStoreCart? {
        let requestBody = try? JSONEncoder().encode(body)
        return try await performBaseRequest(path: path, httpMethod: httpMethod, body: requestBody)
    }

    /// **NEU: Zentraler Handler für Anfragen OHNE Body (GET, DELETE).**
    @discardableResult // KORREKTUR: Fügt das Attribut hinzu, um Warnungen zu unterdrücken.
    private func performCartRequest(path: String, httpMethod: String) async throws -> WooCommerceStoreCart? {
        return try await performBaseRequest(path: path, httpMethod: httpMethod, body: nil)
    }
    
    /// **NEU: Gemeinsame Basis-Implementierung für alle Anfragen.**
    @discardableResult // KORREKTUR: Fügt das Attribut hinzu, um Warnungen zu unterdrücken.
    private func performBaseRequest(path: String, httpMethod: String, body: Data?) async throws -> WooCommerceStoreCart? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: storeApiBaseURL + path) else { throw WooCommerceAPIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = self.cartToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }

            if let newToken = httpResponse.value(forHTTPHeaderField: "cart-token"), newToken != self.cartToken {
                self.cartToken = newToken
                try KeychainHelper.saveCartToken(newToken)
                print("🛒 CartAPIManager: New cart-token received and saved to Keychain.")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
                print("🔴 CartAPIManager Error: Status \(httpResponse.statusCode). Body: \(errorBody)")
                let apiError = WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: "Serverfehler: \(httpResponse.statusCode)", errorCode: nil)
                self.errorMessage = apiError.localizedDescription
                throw apiError
            }
            
            if data.isEmpty {
                self.currentCart = nil
                try KeychainHelper.deleteCartToken()
                self.cartToken = nil
                print("🛒 CartAPIManager: Received empty data, cart is now empty.")
                return nil
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let updatedCart = try decoder.decode(WooCommerceStoreCart.self, from: data)
            
            self.currentCart = updatedCart
            return updatedCart
            
        } catch {
            print("🔴 CartAPIManager: Failed to perform request for path '\(path)': \(error)")
            if error is KeychainError {
                self.errorMessage = "Ein Sicherheitsproblem ist aufgetreten."
            } else if self.errorMessage == nil {
                self.errorMessage = "Ein Netzwerkfehler ist aufgetreten."
            }
            throw error
        }
    }
}
