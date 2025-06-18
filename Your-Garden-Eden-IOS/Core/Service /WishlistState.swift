// DATEI: WishlistState.swift
// PFAD: Services/App/WishlistState.swift
// VERSION: 2.2 (FEHLER BEHOBEN)
// ZWECK: Verwaltet den Zustand der Wunschliste, synchronisiert sie zwischen Gast-
//        und eingeloggtem Zustand und interagiert mit der API.

import Foundation
import Combine

@MainActor
final class WishlistState: ObservableObject {
    
    @Published private(set) var wishlistProductIds: Set<Int> = []
    @Published private(set) var wishlistProducts: [WooCommerceProduct] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authManager = AuthManager.shared
    private let wcApi = WooCommerceAPIManager.shared // Benötigt für das Laden von Produkt-Objekten
    private var cancellables = Set<AnyCancellable>()
    private var fetchProductsTask: Task<Void, Never>?
    private let guestWishlistKey = "guestWishlistProductIDs_v2"
    private let wishlistAPI = AppConfig.YGE.self // Direkter Zugriff auf die YGE-API-Pfade

    init() {
        observeAuthenticationChanges()
        if !authManager.isLoggedIn { loadGuestWishlist() }
        else { Task { await fetchWishlistFromServer() } }
    }

    func isProductInWishlist(productId: Int) -> Bool {
        wishlistProductIds.contains(productId)
    }
    
    func toggleWishlistStatus(for product: WooCommerceProduct) {
        let parentId = product.parent_id ?? product.id
        if isProductInWishlist(productId: parentId) { removeProduct(productId: parentId) }
        else { addProduct(product: product) }
    }
    
    func fetchWishlistFromServer() async {
        guard authManager.isLoggedIn, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // KORREKTUR: Greift auf die neue, private API-Funktion zu, statt auf den wcApiService.
            let wishlistResponse = try await performWishlistRequest(endpoint: wishlistAPI.wishlist, method: "GET", decodingType: YGEWishlist.self)
            let serverIDs = Set(wishlistResponse.items.map { $0.productId })
            
            if serverIDs != self.wishlistProductIds {
                self.wishlistProductIds = serverIDs
                await fetchFullProducts()
            }
        } catch {
            self.errorMessage = "Ihre Wunschliste konnte nicht geladen werden."
            self.wishlistProducts.removeAll(); self.wishlistProductIds.removeAll()
        }
        isLoading = false
    }

    private func observeAuthenticationChanges() {
        authManager.$isLoggedIn.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] isLoggedIn in
            Task { await self?.handleAuthChange(isLoggedIn: isLoggedIn) }
        }.store(in: &cancellables)
    }
    
    private func handleAuthChange(isLoggedIn: Bool) async {
        fetchProductsTask?.cancel()
        self.wishlistProductIds.removeAll(); self.wishlistProducts.removeAll()
        
        if isLoggedIn {
            let guestIDs = UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? []
            UserDefaults.standard.removeObject(forKey: guestWishlistKey)
            await fetchWishlistFromServer()
            
            let missingIDs = guestIDs.filter { !self.wishlistProductIds.contains($0) }
            if !missingIDs.isEmpty {
                for productId in missingIDs {
                    // KORREKTUR: Greift auf die neue, interne API-Funktion zu.
                    Task(priority: .background) { _ = try? await self.addToWishlistAPI(productId: productId, variationId: nil) }
                }
                self.wishlistProductIds.formUnion(missingIDs)
                await fetchFullProducts()
            }
        } else {
            loadGuestWishlist()
        }
    }

    private func addProduct(product: WooCommerceProduct) {
        let parentId = product.parent_id ?? product.id
        guard !wishlistProductIds.contains(parentId) else { return }
        
        wishlistProductIds.insert(parentId)
        if !wishlistProducts.contains(where: { ($0.parent_id ?? $0.id) == parentId }) {
            wishlistProducts.insert(product, at: 0)
        }
        
        Task(priority: .background) {
            if authManager.isLoggedIn {
                let variationId = (product.parent_id != nil) ? product.id : nil
                do {
                    // KORREKTUR: Greift auf die neue, interne API-Funktion zu.
                    _ = try await addToWishlistAPI(productId: parentId, variationId: variationId)
                } catch {
                    await MainActor.run { removeProductFromLocalState(productId: parentId) }
                }
            } else {
                saveGuestWishlist()
            }
        }
    }
    
    private func removeProduct(productId: Int) {
        let originalProducts = self.wishlistProducts
        removeProductFromLocalState(productId: productId)
        
        Task(priority: .background) {
            if authManager.isLoggedIn {
                do {
                    // KORREKTUR: Greift auf die neue, interne API-Funktion zu.
                    _ = try await removeFromWishlistAPI(productId: productId, variationId: nil)
                } catch {
                    await MainActor.run { self.wishlistProductIds.insert(productId); self.wishlistProducts = originalProducts }
                }
            } else {
                saveGuestWishlist()
            }
        }
    }
    
    // MARK: - API Call Wrappers
    
    private func addToWishlistAPI(productId: Int, variationId: Int?) async throws -> YGEWishlist {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        return try await performWishlistRequest(endpoint: wishlistAPI.addToWishlist, method: "POST", body: body, decodingType: YGEWishlist.self)
    }
    
    private func removeFromWishlistAPI(productId: Int, variationId: Int?) async throws -> YGEWishlist {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        return try await performWishlistRequest(endpoint: wishlistAPI.removeFromWishlist, method: "POST", body: body, decodingType: YGEWishlist.self)
    }
    
    // MARK: - Private API Request Helper
    
    private func performWishlistRequest<T: Decodable>(endpoint: String, method: String, body: [String: Any?]? = nil, decodingType: T.Type) async throws -> T {
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
            throw WooCommerceAPIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: "Wishlist API Error", errorCode: nil)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Helper Functions
    
    private func fetchFullProducts() async {
        fetchProductsTask?.cancel()
        let idsToFetch = Array(wishlistProductIds)
        guard !idsToFetch.isEmpty else { self.wishlistProducts = []; return }
        
        self.fetchProductsTask = Task {
            do {
                var params = ProductFilterParameters(); params.include = idsToFetch
                let responseContainer = try await wcApi.fetchProducts(params: params)
                if !Task.isCancelled {
                    let productMap = Dictionary(uniqueKeysWithValues: responseContainer.products.map { ($0.id, $0) })
                    self.wishlistProducts = idsToFetch.compactMap { productMap[$0] }
                }
            } catch {
                if !Task.isCancelled { self.errorMessage = "Produktdetails der Wunschliste konnten nicht geladen werden." }
            }
        }
        await self.fetchProductsTask?.value
    }

    private func removeProductFromLocalState(productId: Int) {
        wishlistProductIds.remove(productId)
        wishlistProducts.removeAll { ($0.parent_id ?? $0.id) == productId }
    }
    
    private func loadGuestWishlist() {
        let guestIDs = UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? []
        self.wishlistProductIds = Set(guestIDs)
        Task { await fetchFullProducts() }
    }
    
    private func saveGuestWishlist() {
        UserDefaults.standard.set(Array(self.wishlistProductIds), forKey: guestWishlistKey)
    }
}
