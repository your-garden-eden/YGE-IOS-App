// DATEI: WishlistState.swift
// PFAD: Features/Wishlist/Services/WishlistState.swift
// VERSION: 2.4 (REPARIERT)
// STATUS: Fehlerbehandlung bei Server-Fehler 500 hinzugefügt.

import Foundation
import Combine

@MainActor
public final class WishlistState: ObservableObject {
    
    public static let shared = WishlistState()
    
    @Published private var _wishlistProducts: [WooCommerceProduct] = []
    @Published public private(set) var wishlistProductIds: Set<Int> = []
    
    public var wishlistProducts: [WooCommerceProduct] {
        return sortProducts(_wishlistProducts)
    }
    
    @Published public var sortOption: WishlistSortOption = .dateAdded {
        didSet { logger.info("Sortieroption geändert auf: \(sortOption.rawValue)") }
    }
    
    @Published public private(set) var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private lazy var authManager = AuthManager.shared
    private let wcApi = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared
    private var cancellables = Set<AnyCancellable>()
    private var fetchProductsTask: Task<Void, Never>?
    private let guestWishlistKey = "guestWishlistProductIDs"
    private let ygeAPI = AppConfig.API.YGE.self

    private init() {
        logger.info("WishlistState initialisiert.")
        observeAuthenticationChanges()
    }

    public func fetchWishlistFromServer() async {
        guard authManager.isLoggedIn, !isLoading else { return }
        isLoading = true; errorMessage = nil; defer { isLoading = false }
        
        do {
            let wishlistResponse: YGEWishlist = try await performWishlistRequest(endpoint: ygeAPI.wishlist, method: "GET")
            let serverIDs = Set((wishlistResponse.items ?? []).map { $0.productId })
            
            if self.wishlistProductIds != serverIDs {
                self.wishlistProductIds = serverIDs
                await fetchFullProducts()
            }
        } catch {
            errorMessage = "Wunschliste konnte nicht geladen werden."
            logger.error("Fehler beim Laden der Server-Wunschliste: \(error.localizedDescription)")
            // KORREKTUR: Bei einem Serverfehler wird die lokale Wunschliste nun explizit geleert,
            // um einen inkonsistenten Zustand zu verhindern.
            self.wishlistProductIds = []
            self._wishlistProducts = []
        }
    }
    
    public func clearWishlist() {
        let idsToRemove = Array(wishlistProductIds)
        wishlistProductIds.removeAll()
        _wishlistProducts.removeAll()
        
        Task(priority: .background) {
            if authManager.isLoggedIn {
                logger.info("Server-seitige Wunschliste wird geleert für \(idsToRemove.count) Produkte.")
                for productId in idsToRemove {
                    try? await updateWishlistOnServer(productId: productId, variationId: nil, add: false)
                }
            } else {
                saveGuestWishlist()
                logger.info("Gast-Wunschliste geleert.")
            }
        }
    }
    
    public func isProductInWishlist(productId: Int) -> Bool {
        return wishlistProductIds.contains(productId)
    }
    
    public func toggleWishlistStatus(for product: WooCommerceProduct) {
        let idForWishlist = product.parentID ?? product.id
        if isProductInWishlist(productId: idForWishlist) {
            removeProduct(productId: idForWishlist)
        } else {
            addProduct(product: product, idForWishlist: idForWishlist)
        }
    }
    
    public func prepareForLogout() async {
        fetchProductsTask?.cancel()
        saveGuestWishlist()
        self.wishlistProductIds.removeAll()
        self._wishlistProducts.removeAll()
    }

    private func addProduct(product: WooCommerceProduct, idForWishlist: Int) {
        guard !wishlistProductIds.contains(idForWishlist) else { return }
        
        wishlistProductIds.insert(idForWishlist)
        if !_wishlistProducts.contains(where: { ($0.parentID ?? $0.id) == idForWishlist }) {
            _wishlistProducts.insert(product, at: 0)
        }
        
        Task(priority: .background) {
            if authManager.isLoggedIn {
                let variationId = product.parentID != nil ? product.id : nil
                do {
                    try await updateWishlistOnServer(productId: idForWishlist, variationId: variationId, add: true)
                } catch {
                    logger.error("Fehler beim Hinzufügen zur Server-Wunschliste: \(error.localizedDescription)")
                }
            } else {
                saveGuestWishlist()
            }
        }
    }
    
    private func removeProduct(productId: Int) {
        wishlistProductIds.remove(productId)
        _wishlistProducts.removeAll { ($0.parentID ?? $0.id) == productId }
        
        Task(priority: .background) {
            if authManager.isLoggedIn {
                do {
                    try await updateWishlistOnServer(productId: productId, variationId: nil, add: false)
                } catch {
                    logger.error("Fehler beim Entfernen von der Server-Wunschliste: \(error.localizedDescription)")
                }
            } else {
                saveGuestWishlist()
            }
        }
    }
    
    private func sortProducts(_ products: [WooCommerceProduct]) -> [WooCommerceProduct] {
        switch sortOption {
        case .dateAdded:
            return products
        case .priceAscending:
            return products.sorted { $0.priceValue < $1.priceValue }
        case .priceDescending:
            return products.sorted { $0.priceValue > $1.priceValue }
        case .nameAscending:
            return products.sorted { $0.name.lowercased() < $1.name.lowercased() }
        }
    }
    
    private func observeAuthenticationChanges() {
        authManager.$authState
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                Task {
                    await self.handleAuthChange(newState: state)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleAuthChange(newState: AuthState) async {
        fetchProductsTask?.cancel()

        if newState == .authenticated {
            let guestIDs = Set(UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? [])
            UserDefaults.standard.removeObject(forKey: guestWishlistKey)
            
            await fetchWishlistFromServer()
            
            let currentServerIDs = self.wishlistProductIds
            let missingIDs = guestIDs.filter { !currentServerIDs.contains($0) }
            
            if !missingIDs.isEmpty {
                logger.info("Synchronisiere \(missingIDs.count) Gast-Wunschlisten-Produkte mit dem Server.")
                for productId in missingIDs {
                    Task(priority: .background) {
                        try? await self.updateWishlistOnServer(productId: productId, variationId: nil, add: true)
                    }
                }
                self.wishlistProductIds.formUnion(missingIDs)
                await fetchFullProducts()
            }
        } else if newState == .guest {
            loadGuestWishlist()
        }
    }
    
    private func updateWishlistOnServer(productId: Int, variationId: Int?, add: Bool) async throws {
        let endpoint = add ? ygeAPI.addToWishlist : ygeAPI.removeFromWishlist
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        _ = try await baseWishlistRequest(endpoint: endpoint, method: "POST", body: body)
        logger.info("Wunschliste auf dem Server für Produkt-ID \(productId) aktualisiert (Hinzufügen: \(add)).")
    }
    
    private func performWishlistRequest<T: Decodable>(endpoint: String, method: String) async throws -> T {
        let (data, _) = try await baseWishlistRequest(endpoint: endpoint, method: method, body: nil)
        let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    private func baseWishlistRequest(endpoint: String, method: String, body: [String: Any?]?) async throws -> (Data, HTTPURLResponse) {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        guard let token = authManager.getAuthToken() else {
            throw WooCommerceAPIError.notAuthenticated
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.invalidURL
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            logger.error("Wishlist API Fehler: Status \(httpResponse.statusCode)")
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: "Wishlist API Error", errorCode: nil)
        }
        
        return (data, httpResponse)
    }

    private func fetchFullProducts() async {
        fetchProductsTask?.cancel()
        
        let idsToFetch = Array(wishlistProductIds)
        guard !idsToFetch.isEmpty else {
            if _wishlistProducts.isEmpty == false { _wishlistProducts = [] }
            return
        }
        
        logger.info("Lade \(idsToFetch.count) vollständige Produkte für die Wunschliste.")
        
        self.fetchProductsTask = Task {
            var params = ProductFilterParameters()
            params.include = idsToFetch
            
            do {
                let response = try await wcApi.fetchProducts(params: params, perPage: idsToFetch.count)
                if !Task.isCancelled {
                    self._wishlistProducts = response.products
                    logger.info("Erfolgreich \(response.products.count) Produkte für die Wunschliste geladen.")
                }
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = "Produktdetails der Wunschliste konnten nicht geladen werden."
                    logger.error("Fehler beim Laden der Wunschlisten-Produktdetails: \(error.localizedDescription)")
                }
            }
        }
        await self.fetchProductsTask?.value
    }
    
    private func loadGuestWishlist() {
        self.wishlistProductIds = Set(UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? [])
        logger.info("Gast-Wunschliste mit \(self.wishlistProductIds.count) IDs geladen.")
        Task { await fetchFullProducts() }
    }
    
    private func saveGuestWishlist() {
        guard !authManager.isLoggedIn else { return }
        UserDefaults.standard.set(Array(self.wishlistProductIds), forKey: guestWishlistKey)
        logger.info("\(self.wishlistProductIds.count) IDs in Gast-Wunschliste gespeichert.")
    }
}

struct YGEWishlist: Decodable {
    let items: [YGEWishlistItem]?
}

struct YGEWishlistItem: Decodable {
    let productId: Int
    let variationId: Int?
}
