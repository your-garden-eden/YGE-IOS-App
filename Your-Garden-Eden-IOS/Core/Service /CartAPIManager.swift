// DATEI: CartAPIManager.swift
// PFAD: Services/App/CartAPIManager.swift
// VERSION: 3.5 (OPERATION: ZERBERSTEN IMPLEMENTIERT - FALLBACK FÜR CLEAR-FUNKTION)

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
    private let cartAPI = AppConfig.WooCommerce.StoreAPI.Cart.self

    private init() {}

    // MARK: - Öffentliche Warenkorb-Aktionen
    
    func getCart(showLoadingIndicator: Bool = false) async {
        await performCartAction(isLoading: showLoadingIndicator) {
            try await self.performRequest(endpoint: self.cartAPI.get, httpMethod: "GET")
        }
    }
    
    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async {
        await performCartAction(isLoading: true) {
            let body: [String: Any] = ["id": variationId ?? productId, "quantity": quantity]
            return try await self.performRequest(endpoint: self.cartAPI.addItem, httpMethod: "POST", body: body)
        }
    }
    
    func updateQuantity(for itemKey: String, newQuantity: Int) async {
        await performCartAction(updatingItemKey: itemKey) {
            try await self.performRequest(endpoint: self.cartAPI.updateItem, httpMethod: "POST", body: ["key": itemKey, "quantity": newQuantity])
        }
    }
    
    func removeItem(key: String) async {
        await performCartAction(updatingItemKey: key) {
            try await self.performRequest(endpoint: self.cartAPI.removeItem, httpMethod: "POST", body: ["key": key])
        }
    }
    
    // ===================================================================
    // **NEUE STRATEGIE: "OPERATION: ZERBERSTEN"**
    // Wenn /cart/clear fehlschlägt, entfernen wir stattdessen alle
    // Artikel einzeln. Dies ist ein robuster Fallback.
    // ===================================================================
    func clearCart() async {
        let itemsToRemove = state.items
        guard !itemsToRemove.isEmpty else { return }

        state.isLoading = true
        state.errorMessage = nil
        
        do {
            // Führe alle "removeItem"-Anfragen parallel aus.
            try await withThrowingTaskGroup(of: Void.self) { group in
                for item in itemsToRemove {
                    group.addTask {
                        _ = try await self.performRequest(endpoint: self.cartAPI.removeItem, httpMethod: "POST", body: ["key": item.key])
                    }
                }
                // Warte, bis alle Aufgaben abgeschlossen sind.
                try await group.waitForAll()
            }
            
            // Nach der Operation den finalen (leeren) Zustand vom Server holen, um 100%ige Konsistenz zu garantieren.
            await getCart(showLoadingIndicator: false)
            
        } catch {
            let apiError = error as? WooCommerceAPIError ?? .underlying(error)
            state.errorMessage = apiError.localizedDescriptionForUser
        }
        
        state.isLoading = false
    }
    
    // MARK: - Private Kernlogik
    
    // Diese private Funktion bleibt bestehen, wird aber von der neuen clearCart-Logik nicht mehr direkt genutzt.
    private func performCartAction(isLoading: Bool = false, updatingItemKey: String? = nil, _ action: @escaping () async throws -> WooCommerceStoreCart?) async {
        state.isLoading = isLoading
        state.updatingItemKey = updatingItemKey
        state.errorMessage = nil
        
        do {
            let newCart = try await action()
            if let newCart = newCart {
                state.items = newCart.safeItems
                state.totals = newCart.totals
            }
        } catch {
            let apiError = error as? WooCommerceAPIError ?? .underlying(error)
            state.errorMessage = apiError.localizedDescriptionForUser
        }
        
        state.isLoading = false
        state.updatingItemKey = nil
    }
    
    @discardableResult
    private func performRequest(endpoint: String, httpMethod: String, body: [String: Any]? = nil) async throws -> WooCommerceStoreCart? {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let cartToken = KeychainHelper.getCartToken() {
            request.setValue(cartToken, forHTTPHeaderField: "Cart-Token")
        }

        if let body = body, !body.isEmpty {
             request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0)) }
        
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "cart-token") {
            try? KeychainHelper.saveCartToken(newCartToken)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let err = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
        
        if data.isEmpty { return WooCommerceStoreCart() }
        
        do {
            return try JSONDecoder().decode(WooCommerceStoreCart.self, from: data)
        } catch let decodingError {
            print("🔴 WARENKORB DECODING FEHLER: \(decodingError) für URL \(url.absoluteString)")
            throw WooCommerceAPIError.decodingError(decodingError)
        }
    }
}
