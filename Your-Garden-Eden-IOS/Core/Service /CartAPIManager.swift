// DATEI: CartAPIManager.swift
// PFAD: Services/App/CartAPIManager.swift
// VERSION: FINAL (OPERATION GLEICHSCHALTUNG 2.0)
// ÄNDERUNG: Der Manager merkt sich nun die Beziehung zwischen Variation und Hauptprodukt,
//           um eine korrekte Datenanreicherung und Navigation zu gewährleisten.

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
        
        // KARTOGRAFIE: Speichert [Variations-ID: Hauptprodukt-ID]
        var variationToParentMap: [Int: Int] = [:]
        var productDetails: [Int: WooCommerceProduct] = [:]
    }

    @Published private(set) var state = State()

    static let shared = CartAPIManager()
    private let cartAPI = AppConfig.WooCommerce.StoreAPI.Cart.self
    private let wcAPI = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared

    private init() {}
    
    func getCart(showLoadingIndicator: Bool = false) async {
        logger.info("Warenkorb wird vom Server abgerufen...")
        await performCartAction(isLoading: showLoadingIndicator) {
            let cart = try await self.performRequest(endpoint: self.cartAPI.get, httpMethod: "GET")
            if let cart = cart, !(cart.items?.isEmpty ?? true) {
                await self.fetchProductDetailsForCartItems(items: cart.safeItems)
            }
            return cart
        }
    }
    
    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async {
        let id = variationId ?? productId
        logger.info("Füge Artikel zum Warenkorb hinzu: Produkt-ID \(productId), Variations-ID \(variationId ?? 0), Menge \(quantity).")
        
        if let variationId = variationId {
            state.variationToParentMap[variationId] = productId
            logger.debug("Mapping gespeichert: Variation \(variationId) -> Parent \(productId)")
        }
        
        await performCartAction(isLoading: true) {
            let cart = try await self.performRequest(endpoint: self.cartAPI.addItem, httpMethod: "POST", body: ["id": id, "quantity": quantity])
            if let cart = cart, !(cart.items?.isEmpty ?? true) {
                await self.fetchProductDetailsForCartItems(items: cart.safeItems)
            }
            return cart
        }
    }
    
    func updateQuantity(for itemKey: String, newQuantity: Int) async {
        logger.info("Aktualisiere Menge für Artikel-Key \(itemKey) auf \(newQuantity).")
        await performCartAction(updatingItemKey: itemKey) {
            let cart = try await self.performRequest(endpoint: self.cartAPI.updateItem, httpMethod: "POST", body: ["key": itemKey, "quantity": newQuantity])
            if let cart = cart, !(cart.items?.isEmpty ?? true) {
                await self.fetchProductDetailsForCartItems(items: cart.safeItems)
            }
            return cart
        }
    }
    
    func removeItem(key: String) async {
        logger.info("Entferne Artikel mit Key \(key) aus dem Warenkorb.")
        await performCartAction(updatingItemKey: key) {
            let cart = try await self.performRequest(endpoint: self.cartAPI.removeItem, httpMethod: "POST", body: ["key": key])
            if let cart = cart, !(cart.items?.isEmpty ?? true) {
                await self.fetchProductDetailsForCartItems(items: cart.safeItems)
            }
            return cart
        }
    }
    
    func clearCart() async {
        let itemsToRemove = state.items
        guard !itemsToRemove.isEmpty else {
            logger.notice("Warenkorb leeren aufgerufen, aber Warenkorb ist bereits leer.")
            return
        }
        logger.info("OPERATION ZERBERSTEN: Leere Warenkorb durch paralleles Löschen von \(itemsToRemove.count) Artikeln.")

        state.isLoading = true
        state.errorMessage = nil
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for item in itemsToRemove {
                    group.addTask {
                        _ = try await self.performRequest(endpoint: self.cartAPI.removeItem, httpMethod: "POST", body: ["key": item.key])
                        await self.logger.debug("Artikel \(item.key) erfolgreich aus Warenkorb entfernt.")
                    }
                }
                try await group.waitForAll()
            }
            
            await getCart(showLoadingIndicator: false)
            logger.info("OPERATION ZERBERSTEN erfolgreich abgeschlossen. Warenkorb ist nun leer.")
            
        } catch {
            let apiError = error as? WooCommerceAPIError ?? .underlying(error)
            state.errorMessage = apiError.localizedDescriptionForUser
            logger.error("OPERATION ZERBERSTEN fehlgeschlagen: \(apiError.localizedDescription)")
        }
        
        state.isLoading = false
    }
    
    private func fetchProductDetailsForCartItems(items: [Item]) async {
        var idsToFetch = Set<Int>()
        for item in items {
            if let parentId = state.variationToParentMap[item.id] {
                idsToFetch.insert(parentId)
            } else {
                idsToFetch.insert(item.id)
            }
        }
        
        guard !idsToFetch.isEmpty else {
            state.productDetails = [:]
            return
        }
        
        logger.info("Beginne Anreicherung für \(idsToFetch.count) Hauptprodukte im Warenkorb.")
        do {
            var params = ProductFilterParameters()
            params.include = Array(idsToFetch)
            let response = try await wcAPI.fetchProducts(params: params, perPage: idsToFetch.count)
            
            var details: [Int: WooCommerceProduct] = [:]
            for product in response.products {
                details[product.id] = product
            }
            self.state.productDetails = details
            logger.info("Anreicherung des Warenkorbs erfolgreich abgeschlossen.")
        } catch {
            logger.error("Fehler bei der Anreicherung des Warenkorbs: \(error.localizedDescription)")
        }
    }
    
    private func performCartAction(isLoading: Bool = false, updatingItemKey: String? = nil, _ action: @escaping () async throws -> WooCommerceStoreCart?) async {
        state.isLoading = isLoading
        state.updatingItemKey = updatingItemKey
        state.errorMessage = nil
        
        do {
            let newCart = try await action()
            if let newCart = newCart {
                state.items = newCart.safeItems
                state.totals = newCart.totals
                
                let currentVariationIds = Set(state.items.map { $0.id })
                state.variationToParentMap = state.variationToParentMap.filter { currentVariationIds.contains($0.key) }
                
            } else {
                state.items = []
                state.totals = nil
                state.productDetails = [:]
                state.variationToParentMap = [:]
            }
        } catch {
            let apiError = error as? WooCommerceAPIError ?? .underlying(error)
            state.errorMessage = apiError.localizedDescriptionForUser
            logger.error("Warenkorb-Aktion fehlgeschlagen: \(apiError.localizedDescriptionForUser)")
        }
        
        state.isLoading = false
        state.updatingItemKey = nil
    }
    
    @discardableResult
    private func performRequest(endpoint: String, httpMethod: String, body: [String: Any]? = nil) async throws -> WooCommerceStoreCart? {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        
        logger.debug("Führe Warenkorb-Anfrage aus: \(httpMethod) an \(url.path)")
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let cartToken = KeychainHelper.getCartToken() {
            request.setValue(cartToken, forHTTPHeaderField: "Cart-Token")
            logger.debug("Verwende existierenden Warenkorb-Token.")
        }

        if let body = body, !body.isEmpty {
             request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0)) }
        
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "cart-token") {
            try? KeychainHelper.saveCartToken(newCartToken)
            logger.info("Neuer Warenkorb-Token empfangen und gespeichert.")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let err = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
            logger.error("Warenkorb-API Server-Fehler (\(httpResponse.statusCode)): \(err?.message ?? "N/A")")
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
        
        if data.isEmpty { return nil }
        
        return try JSONDecoder().decode(WooCommerceStoreCart.self, from: data)
    }
}
