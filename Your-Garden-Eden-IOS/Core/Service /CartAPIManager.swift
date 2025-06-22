// DATEI: CartAPIManager.swift
// PFAD: Services/App/CartAPIManager.swift
// VERSION: ADLERKRALLE 1.0 (MODIFIZIERT)

import Foundation
import StoreKit
import AppIntents
import CoreTransferable
import Combine

@MainActor
final class CartAPIManager: ObservableObject {
    struct State {
        var items: [Item] = []
        var totals: Totals? = nil
        var coupons: [WooCommerceStoreCoupon] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var updatingItemKey: String? = nil
        var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
        
        var variationToParentMap: [Int: Int] = [:]
        var productDetails: [Int: WooCommerceProduct] = [:]
    }

    @Published private(set) var state = State()

    static let shared = CartAPIManager()
    private let cartAPI = AppConfig.API.WCStore.self
    private let wcAPI = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared
    
    private lazy var authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        observeAuthenticationChanges()
    }
    
    func prepareForLogout() {
        logger.info("Bereite Warenkorb für Logout vor. Der aktuelle Warenkorb wird zur Gast-Sitzung.")
        self.state = State()
    }
    
    private func observeAuthenticationChanges() {
        authManager.$authState
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.logger.info("CartAPIManager: Auth-Zustand hat sich geändert auf: \(state).")
                Task {
                    await self?.handleAuthChange(newState: state)
                }
            }
            .store(in: &cancellables)
    }

    private func handleAuthChange(newState: AuthState) async {
        if newState == .guest || newState == .authenticated {
            logger.info("Synchronisiere Warenkorb aufgrund von Auth-Änderung.")
            await getCart(showLoadingIndicator: true)
        }
    }
    
    func getCart(showLoadingIndicator: Bool = false) async {
        logger.info("Warenkorb wird vom Server abgerufen...")
        await performCartAction(isLoading: showLoadingIndicator) {
            let cart = try await self.performRequest(endpoint: self.cartAPI.cart, httpMethod: "GET")
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
            let cart = try await self.performRequest(endpoint: self.cartAPI.cartAddItem, httpMethod: "POST", body: ["id": id, "quantity": quantity])
            if let cart = cart, !(cart.items?.isEmpty ?? true) {
                await self.fetchProductDetailsForCartItems(items: cart.safeItems)
            }
            return cart
        }
    }
    
    func updateQuantity(for itemKey: String, newQuantity: Int) async {
        logger.info("Aktualisiere Menge für Artikel-Key \(itemKey) auf \(newQuantity).")
        await performCartAction(updatingItemKey: itemKey) {
            let cart = try await self.performRequest(endpoint: self.cartAPI.cartUpdateItem, httpMethod: "POST", body: ["key": itemKey, "quantity": newQuantity])
            if let cart = cart, !(cart.items?.isEmpty ?? true) {
                await self.fetchProductDetailsForCartItems(items: cart.safeItems)
            }
            return cart
        }
    }
    
    func removeItem(key: String) async {
        logger.info("Entferne Artikel mit Key \(key) aus dem Warenkorb.")
        await performCartAction(updatingItemKey: key) {
            let cart = try await self.performRequest(endpoint: self.cartAPI.cartRemoveItem, httpMethod: "POST", body: ["key": key])
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
                        _ = try await self.performRequest(endpoint: self.cartAPI.cartRemoveItem, httpMethod: "POST", body: ["key": item.key])
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

    func applyCoupon(code: String) async {
        guard !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logger.warning("OPERATION GUTSCHEIN: Versuch, einen leeren Gutscheincode anzuwenden, abgebrochen.")
            return
        }
        
        logger.info("OPERATION GUTSCHEIN: Versuche Gutschein '\(code)' anzuwenden.")
        await performCartAction(isLoading: true) {
            let body = ["code": code]
            let cart = try await self.performRequest(endpoint: self.cartAPI.cartApplyCoupon, httpMethod: "POST", body: body)
            if let newCart = cart, let _ = newCart.errors?.first {
                throw WooCommerceAPIError.serverError(statusCode: 200, message: "Gutschein ungültig oder nicht anwendbar.", errorCode: "coupon_invalid")
            }
            return cart
        }
    }

    func removeCoupon(code: String) async {
        logger.info("OPERATION GUTSCHEIN: Entferne Gutschein '\(code)'.")
        await performCartAction(isLoading: true) {
            let body = ["code": code]
            let cart = try await self.performRequest(endpoint: self.cartAPI.cartRemoveCoupon, httpMethod: "POST", body: body)
            return cart
        }
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
                state.coupons = newCart.coupons ?? []
                
                let currentVariationIds = Set(state.items.map { $0.id })
                state.variationToParentMap = state.variationToParentMap.filter { currentVariationIds.contains($0.key) }
                
            } else {
                state.items = []
                state.totals = nil
                state.coupons = []
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
        
        // --- BEGINN MODIFIKATION ---
        // Fügt den Authentifizierungs-Header hinzu, wenn der Benutzer eingeloggt ist.
        // Dies "kettet" den Warenkorb an das Benutzerkonto.
        if let token = authManager.getAuthToken(), authManager.isLoggedIn {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            logger.debug("Führe Warenkorb-Anfrage als eingeloggter Benutzer aus.")
        }
        // --- ENDE MODIFIKATION ---
        
        if let cartToken = KeychainService.getCartToken() {
            request.setValue(cartToken, forHTTPHeaderField: "Cart-Token")
            logger.debug("Verwende existierenden Warenkorb-Token.")
        }

        if let body = body, !body.isEmpty {
             request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0)) }
        
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "cart-token") {
            KeychainService.saveCartToken(newCartToken)
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
