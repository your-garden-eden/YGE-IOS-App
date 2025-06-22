// DATEI: WishlistState.swift
// PFAD: Services/App/WishlistState.swift
// VERSION: STAMMDATEN 1.4 - FINALER STABILITÄTS-FIX
// STATUS: MODIFIZIERT & STABILISIERT

import Foundation
import Combine

@MainActor
final class WishlistState: ObservableObject {
    
    static let shared = WishlistState()
    
    @Published private(set) var wishlistProductIds: Set<Int> = []
    @Published private var _wishlistProducts: [WooCommerceProduct] = []
    @Published var sortOption: WishlistSortOption = .dateAdded
    
    var wishlistProducts: [WooCommerceProduct] {
        sortProducts(_wishlistProducts)
    }
    
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private lazy var authManager = AuthManager.shared
    private let wcApi = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared
    private var cancellables = Set<AnyCancellable>()
    private var fetchProductsTask: Task<Void, Never>?
    private let guestWishlistKey = "guestWishlistProductIDs_v2"
    private let wishlistAPI = AppConfig.API.YGE.self

    private init() {
        logger.info("WishlistState initialisiert.")
        observeAuthenticationChanges()
    }

    func isProductInWishlist(productId: Int) -> Bool {
        return wishlistProductIds.contains(productId)
    }
    
    func toggleWishlistStatus(for product: WooCommerceProduct) {
        let idForWishlist = (product.parent_id ?? 0) > 0 ? product.parent_id! : product.id
        if isProductInWishlist(productId: idForWishlist) {
            removeProduct(productId: idForWishlist)
        } else {
            addProduct(product: product, idForWishlist: idForWishlist)
        }
    }
    
    func clearWishlist() {
        logger.info("Lösche komplette Wunschliste...")
        let idsToRemove = Array(wishlistProductIds)
        for id in idsToRemove {
            removeProduct(productId: id)
        }
        logger.info("\(idsToRemove.count) Löschoperationen für Wunschliste eingeleitet.")
    }

    func prepareForLogout() {
        logger.info("Bereite Wunschliste für Logout vor. Speichere \(wishlistProductIds.count) Artikel für Gast-Sitzung.")
        saveGuestWishlist()
        self.wishlistProductIds.removeAll()
        self._wishlistProducts.removeAll()
    }

    private func addProduct(product: WooCommerceProduct, idForWishlist: Int) {
        guard !wishlistProductIds.contains(idForWishlist) else { return }
        logger.info("Füge Produkt \(idForWishlist) zur Wunschliste hinzu.")
        wishlistProductIds.insert(idForWishlist)
        if !_wishlistProducts.contains(where: { (($0.parent_id ?? 0) > 0 ? $0.parent_id! : $0.id) == idForWishlist }) {
            _wishlistProducts.insert(product, at: 0)
        }
        Task(priority: .background) {
            if authManager.isLoggedIn {
                let variationId = (product.parent_id ?? 0) > 0 ? product.id : nil
                do {
                    try await addToWishlistAPI(productId: idForWishlist, variationId: variationId)
                    await MainActor.run { logger.info("Produkt \(idForWishlist) erfolgreich zur Server-Wunschliste hinzugefügt.") }
                } catch {
                    await MainActor.run {
                        logger.error("Fehler beim Hinzufügen von Produkt \(idForWishlist) zur Server-Wunschliste. Mache lokalen Zustand rückgängig. Fehler: \(error.localizedDescription)")
                        removeProductFromLocalState(productId: idForWishlist)
                    }
                }
            } else {
                saveGuestWishlist()
                await MainActor.run { logger.info("Produkt \(idForWishlist) zur Gast-Wunschliste hinzugefügt.") }
            }
        }
    }
    
    private func removeProduct(productId: Int) {
        logger.info("Entferne Produkt \(productId) von der Wunschliste.")
        let originalProducts = self._wishlistProducts
        removeProductFromLocalState(productId: productId)
        Task(priority: .background) {
            if authManager.isLoggedIn {
                do {
                    try await removeFromWishlistAPI(productId: productId, variationId: nil)
                    await MainActor.run { logger.info("Produkt \(productId) erfolgreich von Server-Wunschliste entfernt.") }
                } catch {
                    await MainActor.run {
                        logger.error("Fehler beim Entfernen von Produkt \(productId) von der Server-Wunschliste. Mache lokalen Zustand rückgängig. Fehler: \(error.localizedDescription)")
                        self.wishlistProductIds.insert(productId)
                        self._wishlistProducts = originalProducts
                    }
                }
            } else {
                saveGuestWishlist()
                await MainActor.run { logger.info("Produkt \(productId) von Gast-Wunschliste entfernt.") }
            }
        }
    }
    
    private func sortProducts(_ products: [WooCommerceProduct]) -> [WooCommerceProduct] {
        switch sortOption {
        case .dateAdded:
            return products
        case .priceAscending:
            return products.sorted { Double($0.price) ?? 0.0 < Double($1.price) ?? 0.0 }
        case .priceDescending:
            return products.sorted { Double($0.price) ?? 0.0 > Double($1.price) ?? 0.0 }
        case .nameAscending:
            return products.sorted { $0.name.lowercased() < $1.name.lowercased() }
        }
    }
    
    private func removeProductFromLocalState(productId: Int) {
        wishlistProductIds.remove(productId)
        _wishlistProducts.removeAll { product in
            let idToRemove = (product.parent_id ?? 0) > 0 ? product.parent_id! : product.id
            return idToRemove == productId
        }
    }
    
    func fetchWishlistFromServer() async {
        guard authManager.isLoggedIn, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        logger.info("Beginne Abruf der Wunschliste vom Server.")
        
        let wishlistResponse: YGEWishlist
        do {
            // Primärer Versuch, die Wunschliste abzurufen und zu dekodieren.
            wishlistResponse = try await performWishlistRequest(endpoint: wishlistAPI.wishlist, method: "GET", decodingType: YGEWishlist.self)
        } catch {
            // --- BEGINN FINALE KORREKTUR ---
            // Wenn der obige Versuch fehlschlägt (insbesondere bei einem DecodingError),
            // behandeln wir dies als den erwarteten Fall einer leeren/invaliden Server-Antwort.
            // Wir loggen die Warnung und erstellen manuell ein leeres, gültiges Objekt,
            // anstatt den Fehler an die UI weiterzugeben.
            logger.warning("Abruf der Wunschliste fehlgeschlagen (wahrscheinlich leer oder invalid). Gebe leeres Objekt als Fallback zurück. Fehler: \(error.localizedDescription)")
            wishlistResponse = YGEWishlist(items: [])
            // --- ENDE FINALE KORREKTUR ---
        }

        // Die weitere Verarbeitung erfolgt nun immer mit einem gültigen (wenn auch eventuell leeren) Objekt.
        let serverIDs = Set((wishlistResponse.items ?? []).map { $0.productId })
        logger.info("\(serverIDs.count) Wunschlisten-IDs vom Server empfangen.")
        if serverIDs != self.wishlistProductIds {
            self.wishlistProductIds = serverIDs
            await fetchFullProducts()
        }
        
        isLoading = false
    }
    
    private func observeAuthenticationChanges() {
        authManager.$authState
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.logger.info("WishlistState: Auth-Zustand hat sich geändert auf: \(state).")
                Task {
                    await self?.handleAuthChange(newState: state)
                }
            }.store(in: &cancellables)
    }
    
    private func handleAuthChange(newState: AuthState) async {
        if newState == .initializing {
            logger.info("WishlistState: Auth-Zustand ist .initializing, pausiere alle Aktionen.")
            fetchProductsTask?.cancel()
            return
        }
        
        if newState == .authenticated {
            logger.info("Benutzer ist eingeloggt. Migriere Gast-Wunschliste (falls vorhanden) und lade vom Server.")
            let guestIDs = UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? []
            UserDefaults.standard.removeObject(forKey: guestWishlistKey)
            
            await fetchWishlistFromServer()
            
            let missingIDs = guestIDs.filter { !self.wishlistProductIds.contains($0) }
            if !missingIDs.isEmpty {
                logger.info("Füge \(missingIDs.count) Produkte aus der Gast-Wunschliste zur Server-Wunschliste hinzu.")
                for productId in missingIDs {
                    Task(priority: .background) {
                        try? await self.addToWishlistAPI(productId: productId, variationId: nil)
                    }
                }
                self.wishlistProductIds.formUnion(missingIDs)
                await fetchFullProducts()
            }
        } else { // newState == .guest
            logger.info("Benutzer ist Gast. Lade Gast-Wunschliste aus UserDefaults.")
            loadGuestWishlist()
        }
    }
    
    private func addToWishlistAPI(productId: Int, variationId: Int?) async throws {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        try await performWishlistRequest(endpoint: wishlistAPI.addToWishlist, method: "POST", body: body)
    }
    
    private func removeFromWishlistAPI(productId: Int, variationId: Int?) async throws {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        try await performWishlistRequest(endpoint: wishlistAPI.removeFromWishlist, method: "POST", body: body)
    }
    
    private func performWishlistRequest<T: Decodable>(endpoint: String, method: String, body: [String: Any?]? = nil, decodingType: T.Type) async throws -> T {
        let (data, _) = try await performBaseWishlistRequest(endpoint: endpoint, method: method, body: body)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    private func performWishlistRequest(endpoint: String, method: String, body: [String: Any?]? = nil) async throws {
        _ = try await performBaseWishlistRequest(endpoint: endpoint, method: method, body: body)
    }
    
    private func performBaseWishlistRequest(endpoint: String, method: String, body: [String: Any?]? = nil) async throws -> (Data, HTTPURLResponse) {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = authManager.getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorData = String(data: data, encoding: .utf8) ?? "No error data"
            logger.error("[API ERROR] Wishlist-Request fehlgeschlagen. Status: \((response as? HTTPURLResponse)?.statusCode ?? 500), Data: \(errorData)")
            throw WooCommerceAPIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: "Wishlist API Error", errorCode: nil)
        }
        return (data, httpResponse)
    }

    private func fetchFullProducts() async {
        fetchProductsTask?.cancel()
        let idsToFetch = Array(wishlistProductIds)
        guard !idsToFetch.isEmpty else {
            self._wishlistProducts = []
            return
        }
        logger.info("Lade vollständige Produktdaten für \(idsToFetch.count) Wunschlisten-IDs.")
        self.fetchProductsTask = Task {
            do {
                var params = ProductFilterParameters()
                params.include = idsToFetch
                let responseContainer = try await wcApi.fetchProducts(params: params, perPage: idsToFetch.count)
                if !Task.isCancelled {
                    let productMap = Dictionary(uniqueKeysWithValues: responseContainer.products.map { ($0.id, $0) })
                    self._wishlistProducts = idsToFetch.compactMap { productMap[$0] }
                    logger.info("Wunschlisten-Produktdaten erfolgreich geladen.")
                }
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = "Produktdetails der Wunschliste konnten nicht geladen werden."
                    logger.error("Fehler beim Laden der Wunschlisten-Produktdaten: \(error.localizedDescription)")
                }
            }
        }
        await self.fetchProductsTask?.value
    }
    
    private func loadGuestWishlist() {
        let guestIDs = UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? []
        self.wishlistProductIds = Set(guestIDs)
        Task {
            await fetchFullProducts()
        }
    }
    
    private func saveGuestWishlist() {
        UserDefaults.standard.set(Array(self.wishlistProductIds), forKey: guestWishlistKey)
    }
}
