//
//  CartAPIManager.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

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
            if AuthManager.shared.getAuthToken() == nil {
                self.cartToken = try? KeychainHelper.getCartToken()
            }
            await getCart()
            self.initializationTask = nil
        }
    }

    private func ensureTokensAreAvailable() async throws {
        if let task = initializationTask { await task.value }
        if AuthManager.shared.getAuthToken() != nil { return }
        if cartToken == nil && cartNonce == nil {
            await getCart()
        }
        guard cartToken != nil || cartNonce != nil else {
            let error = WooCommerceAPIError.internalError("Could not obtain GUEST auth token.")
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Public API
    
    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async throws {
        try await ensureTokensAreAvailable()
        var body: [String: Any]
        if let variationId = variationId, variationId > 0 {
             body = ["id": variationId, "quantity": quantity]
        } else {
             body = ["id": productId, "quantity": quantity]
        }
        let cart = try await performCartRequest(path: "cart/add-item", httpMethod: "POST", body: body)
        updateCart(with: cart)
    }
    
    func updateItemQuantity(itemKey: String, quantity: Int) async throws {
        try await ensureTokensAreAvailable()
        let body = ["quantity": quantity]
        let cart = try await performCartRequest(path: "cart/items/\(itemKey)", httpMethod: "PUT", body: body)
        updateCart(with: cart)
    }
    
    func removeItem(itemKey: String) async throws {
        try await ensureTokensAreAvailable()
        let cart = try await performCartRequest(path: "cart/items/\(itemKey)", httpMethod: "DELETE")
        updateCart(with: cart)
    }
    
    func clearCart() async throws {
        try await ensureTokensAreAvailable()
        let cart = try await performCartRequest(path: "cart/items", httpMethod: "DELETE")
        updateCart(with: cart)
    }
    
    func getCart() async {
        let cart = try? await performCartRequest(path: "cart", httpMethod: "GET")
        updateCart(with: cart)
    }
    
    // MARK: - Safe Update Helper
    
    /// **NEU: Eine sichere Methode zum Aktualisieren des Warenkorbs.**
    /// Sie stellt sicher, dass die Zuweisung zum @Published-Property nicht mit dem View-Update-Zyklus kollidiert.
    private func updateCart(with cart: WooCommerceStoreCart?) {
        Task { @MainActor in
            self.currentCart = cart
        }
    }
    
    // MARK: - Private Request Logic
    
    @discardableResult
    private func performCartRequest(path: String, httpMethod: String, body: [String: Any]? = nil) async throws -> WooCommerceStoreCart? {
        var requestBody: Data? = nil
        if let body = body {
            requestBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        return try await performBaseRequest(path: path, httpMethod: httpMethod, body: requestBody)
    }

    private func performBaseRequest(path: String, httpMethod: String, body: Data?) async throws -> WooCommerceStoreCart? {
        // HINWEIS: isLoading und errorMessage werden jetzt in einer eigenen Task-Kapsel gesetzt.
        Task { @MainActor in isLoading = true; errorMessage = nil }
        defer {
            Task { @MainActor in isLoading = false }
        }
        
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
            if let token = self.cartToken { request.setValue(token, forHTTPHeaderField: "Cart-Token") }
            if let nonce = self.cartNonce { request.setValue(nonce, forHTTPHeaderField: "X-WC-Store-API-Nonce") }
        }
        
        if let body = body { request.httpBody = body }
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])) }

            if let newNonce = httpResponse.value(forHTTPHeaderField: "X-WC-Store-API-Nonce") { self.cartNonce = newNonce }
            
            if AuthManager.shared.getAuthToken() == nil {
                if let newToken = httpResponse.value(forHTTPHeaderField: "Cart-Token"), newToken != self.cartToken {
                    self.cartToken = newToken; try KeychainHelper.saveCartToken(newToken)
                }
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"; print("🔴 CartAPIManager Error: Status \(httpResponse.statusCode). Body: \(errorBody)")
                let apiError = WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: "Serverfehler: \(httpResponse.statusCode)", errorCode: nil)
                Task { @MainActor in self.errorMessage = apiError.localizedDescription }; throw apiError
            }
            
            if data.isEmpty { return nil }
            let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WooCommerceStoreCart.self, from: data)
        } catch {
            print("🔴 CartAPIManager: Failed to perform request for path '\(path)': \(error)")
            let finalErrorMsg = (error as? KeychainError) != nil ? "Ein Sicherheitsproblem ist aufgetreten." : "Ein Netzwerkfehler ist aufgetreten."
            Task { @MainActor in if self.errorMessage == nil { self.errorMessage = finalErrorMsg } }; throw error
        }
    }
}
