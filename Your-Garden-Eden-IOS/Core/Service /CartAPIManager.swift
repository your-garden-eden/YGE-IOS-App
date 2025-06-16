// Path: Your-Garden-Eden-IOS/Core/Service/CartAPIManager.swift
// VERSION 2.2 (FINAL - Bulletproof Add-to-Cart Logic)

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
            try await self.performCartRequest(path: "cart", httpMethod: "GET")
        }
    }
    
    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async {
        await performCartAction(isLoading: true) {
            let idToAdd = variationId ?? productId
            let body: [String: Any] = ["id": idToAdd, "quantity": quantity]
            
            // ===================================================================
            // **HIER IST DIE NEUE "ABFANGJÄGER"-LOGIK**
            // Wir führen zuerst die POST-Anfrage aus.
            // Anstatt ihre Antwort zu dekodieren, betrachten wir einen Erfolg als Signal,
            // den Warenkorb sofort neu und sauber abzufragen.
            // ===================================================================
            _ = try await self.performWriteRequest(path: "cart/add-item", httpMethod: "POST", body: body)
            
            // Jetzt, wo der Artikel auf dem Server hinzugefügt wurde, holen wir den
            // garantiert korrekten und aktuellen Warenkorb-Zustand.
            return try await self.performCartRequest(path: "cart", httpMethod: "GET")
        }
    }
    
    func updateQuantity(for item: Item, newQuantity: Int) async {
        await performCartAction(updatingItemKey: item.key) {
            _ = try await self.performWriteRequest(path: "cart/items/\(item.key)", httpMethod: "PUT", body: ["quantity": newQuantity])
            return try await self.performCartRequest(path: "cart", httpMethod: "GET")
        }
    }
    
    func removeItem(_ item: Item) async {
        await performCartAction(updatingItemKey: item.key) {
            _ = try await self.performWriteRequest(path: "cart/items/\(item.key)", httpMethod: "DELETE")
            // Die Store API gibt bei Erfolg einen leeren Body zurück. Wir müssen den Cart neu laden.
            return try await self.performCartRequest(path: "cart", httpMethod: "GET")
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
            state.errorMessage = apiError.localizedDescriptionForUser
            print("🔴 CartAPIManager Error: \(error.localizedDescription)")
        }
        
        state.isLoading = false
        state.updatingItemKey = nil
    }
    
    /// **NEU:** Eine private Funktion für schreibende Anfragen (POST, PUT, DELETE), die keine Antwort dekodiert.
    private func performWriteRequest(path: String, httpMethod: String, body: [String: Any]? = nil) async throws {
        guard let url = URL(string: AppConfig.WooCommerce.storeApiBaseURL + "v1/" + path) else {
            throw WooCommerceAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let cartToken = KeychainHelper.getCartToken() {
            request.setValue(cartToken, forHTTPHeaderField: "Cart-Token")
            print("ℹ️ Cart Token attached to request header for WRITE action.")
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."]))
        }
        
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "cart-token") {
            try? KeychainHelper.saveCartToken(newCartToken)
            print("✅ New Cart Token received from WRITE action and saved.")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let rawError = String(data: data, encoding: .utf8) {
                print("💡 SERVER ERROR RESPONSE (raw): \(rawError)")
            }
            let err = try? JSONDecoder().decode(WooCommerceStoreErrorResponse.self, from: data)
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
    }
    
    /// Private Funktion für lesende Anfragen, die einen Warenkorb dekodiert.
    @discardableResult
    private func performCartRequest(path: String, httpMethod: String) async throws -> WooCommerceStoreCart? {
        guard let url = URL(string: AppConfig.WooCommerce.storeApiBaseURL + "v1/" + path) else {
            throw WooCommerceAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let cartToken = KeychainHelper.getCartToken() {
            request.setValue(cartToken, forHTTPHeaderField: "Cart-Token")
            print("ℹ️ Cart Token attached to request header for READ action.")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0))
        }
        
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "cart-token") {
            try? KeychainHelper.saveCartToken(newCartToken)
            print("✅ New Cart Token received from READ action and saved.")
        }

        if httpResponse.statusCode == 404 {
            print("🛒 Cart not found (404), treating as an empty cart."); try? KeychainHelper.deleteCartToken()
            return WooCommerceStoreCart(items: [], totals: nil)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let err = try? JSONDecoder().decode(WooCommerceStoreErrorResponse.self, from: data)
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
        
        if data.isEmpty {
            return WooCommerceStoreCart(items: [], totals: nil)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WooCommerceStoreCart.self, from: data)
        } catch {
            print("🔴 Decoding cart failed (Error: \(error.localizedDescription)). This is likely a guest user with an empty cart. Treating as empty.")
            return WooCommerceStoreCart(items: [], totals: nil)
        }
    }
}
