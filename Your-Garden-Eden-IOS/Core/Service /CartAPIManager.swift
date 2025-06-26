// DATEI: CartAPIManager.swift
// PFAD: Features/Cart/Services/CartAPIManager.swift
// VERSION: 2.2 (ANGEPASST)
// STATUS: Typkonflikt bei Adressen behoben.

import Foundation
import Combine

@MainActor
public final class CartAPIManager: ObservableObject {
    public struct State {
        var items: [Item] = []
        var totals: Totals?
        var coupons: [Coupon] = []
        var isLoading: Bool = false
        var errorMessage: String?
        var updatingItemKey: String?
        var variationToParentMap: [Int: Int] = [:]
        var productDetails: [Int: WooCommerceProduct] = [:]
    }

    @Published public private(set) var state = State()

    public static let shared = CartAPIManager()
    
    private let cartAPI = AppConfig.API.WCStore.self
    private let ygeAPI = AppConfig.API.YGE.self
    private let wcAPI = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared
    private lazy var authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        observeAuthenticationChanges()
    }
    
    // ... (Andere Public API Funktionen bleiben unverändert) ...
    public func getCart(showLoadingIndicator: Bool = true) async { /* ... */ }
    public func clearCart() async { /* ... */ }
    public func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async { /* ... */ }
    public func removeItem(key: String) async { /* ... */ }
    public func updateQuantity(for key: String, newQuantity: Int) async { /* ... */ }
    public func applyCoupon(code: String) async { /* ... */ }
    public func removeCoupon(code: String) async { /* ... */ }
    public func clearErrorMessage() { /* ... */ }
    public func prepareForLogout() async { /* ... */ }


    public func stageCartForCheckout() async -> IdentifiableURL? {
        state.isLoading = true; defer { state.isLoading = false }
        
        guard let addresses = try? await ProfileAPIManager.shared.fetchProfileAndAddresses() else {
            state.errorMessage = "Ihre Adressdaten konnten nicht geladen werden."
            return nil
        }
        
        let itemPayloads = state.items.map { CartItemPayload(productId: state.variationToParentMap[$0.id] ?? $0.id, variationId: state.variationToParentMap[$0.id] != nil ? $0.id : 0, quantity: $0.quantity) }
        
        // ===================================================================
        // === BEGINN KORREKTUR #7.2                                       ===
        // ===================================================================
        // ANPASSUNG: Die neuen Konvertierungsfunktionen werden hier aufgerufen.
        
        let billingAddressForAPI = addresses.billing.asBillingAddress(email: authManager.user?.email)
        let shippingAddressForAPI = addresses.shipping.asShippingAddress()
        
        let payload = StagedCartPayload(
            items: itemPayloads,
            billingAddress: billingAddressForAPI,
            shippingAddress: shippingAddressForAPI
        )
        // ===================================================================
        // === ENDE KORREKTUR #7.2                                         ===
        // ===================================================================
        
        do {
            let response: StagedCartResponse = try await performYGEAuthenticatedRequest(to: ygeAPI.stageCartForPopulation, body: payload)
            var components = URLComponents(string: "https://www.your-garden-eden.de/checkout")!
            components.queryItems = [URLQueryItem(name: "yge_cart_token", value: response.token)]
            if let jwt = authManager.getAuthToken() { components.queryItems?.append(URLQueryItem(name: "JWT", value: jwt)) }
            
            guard let finalUrl = components.url else { throw URLError(.badURL) }
            return IdentifiableURL(url: finalUrl)
        } catch {
            state.errorMessage = "Checkout konnte nicht vorbereitet werden."
            return nil
        }
    }
    
    // MARK: - Private Logic
    
    private func observeAuthenticationChanges() {
        authManager.$authState.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] state in
            guard let self else { return }
            logger.info("Auth-Status Änderung im CartAPIManager erkannt: \(state). Warenkorb wird neu geladen.")
            Task { await self.getCart() }
        }.store(in: &cancellables)
    }

    private func performCartAction(isLoading: Bool = false, _ action: @escaping () async throws -> WooCommerceStoreCart?) async {
        if isLoading { state.isLoading = true }
        state.errorMessage = nil
        
        do {
            let newCart = try await action()
            if newCart == nil {
                state = State()
            } else {
                let items = newCart?.safeItems ?? []
                state.items = items
                state.totals = newCart?.totals
                state.coupons = newCart?.coupons ?? []
                if !items.isEmpty { await fetchProductDetailsForCartItems(items: items) }
            }
        } catch {
            state.errorMessage = (error as? WooCommerceAPIError ?? .underlying(error)).localizedDescriptionForUser
            logger.error("CartAPIManager Fehler: \(state.errorMessage ?? "Unbekannt")")
        }
        
        state.isLoading = false
    }
    
    private func fetchProductDetailsForCartItems(items: [Item]) async {
        let idsToFetch = Set(items.map { state.variationToParentMap[$0.id] ?? $0.id })
        guard !idsToFetch.isEmpty else { return }
        
        var params = ProductFilterParameters(); params.include = Array(idsToFetch)
        if let response = try? await wcAPI.fetchProducts(params: params, perPage: idsToFetch.count) {
            self.state.productDetails = Dictionary(uniqueKeysWithValues: response.products.map { ($0.id, $0) })
        }
    }
    
    @discardableResult
    private func performRequest(endpoint: String, httpMethod: String, body: [String: Any]? = nil) async throws -> WooCommerceStoreCart? {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authManager.isLoggedIn, let token = authManager.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let cartToken = KeychainService.getCartToken() {
            request.setValue(cartToken, forHTTPHeaderField: "Cart-Token")
        }
        if let body = body { request.httpBody = try? JSONSerialization.data(withJSONObject: body) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.invalidURL }
        
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "cart-token") {
            KeychainService.saveCartToken(newCartToken)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let err = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
        
        if httpMethod == "DELETE" || data.isEmpty { return nil }
        
        let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(WooCommerceStoreCart.self, from: data)
    }
    
    private func performYGEAuthenticatedRequest<T: Decodable, B: Encodable>(to urlString: String, body: B) async throws -> T {
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard authManager.isLoggedIn, let token = authManager.getAuthToken() else { throw WooCommerceAPIError.notAuthenticated }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw WooCommerceAPIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: "Request failed", errorCode: nil)
        }
        
        let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
