// DATEI: WishlistState.swift
// VERSION: ENDSIEG 2.0 (ERWEITERT UM CLEAR-FUNKTION)
// ZWECK: Stellt nun eine Funktion zum Löschen der gesamten Wunschliste bereit.

import Foundation
import Combine

enum WishlistSortOption: String, CaseIterable, Identifiable {
    case dateAdded = "Neueste zuerst"
    case priceAscending = "Preis: aufsteigend"
    case priceDescending = "Preis: absteigend"
    case nameAscending = "Name: A-Z"
    
    var id: String { self.rawValue }
}

@MainActor
final class WishlistState: ObservableObject {
    
    @Published private(set) var wishlistProductIds: Set<Int> = []
    @Published private var _wishlistProducts: [WooCommerceProduct] = []
    @Published var sortOption: WishlistSortOption = .dateAdded
    
    var wishlistProducts: [WooCommerceProduct] {
        sortProducts(_wishlistProducts)
    }
    
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let authManager = AuthManager.shared
    private let wcApi = WooCommerceAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var fetchProductsTask: Task<Void, Never>?
    private let guestWishlistKey = "guestWishlistProductIDs_v2"
    private let wishlistAPI = AppConfig.YGE.self

    init() { /* ... unverändert ... */ }

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
    
    // ===================================================================
    // **NEUE FUNKTION: WUNSCHLISTE LEEREN**
    // ===================================================================
    func clearWishlist() {
        print("[WishlistState] >> clearWishlist AUFGERUFEN.")
        // Erstellt eine Kopie der IDs, um sicher zu iterieren,
        // während das Original-Set modifiziert wird.
        let idsToRemove = Array(wishlistProductIds)
        for id in idsToRemove {
            // Ruft die bestehende remove-Funktion für jeden Artikel auf,
            // um sicherzustellen, dass auch die API-Aufrufe korrekt erfolgen.
            removeProduct(productId: id)
        }
        print("[WishlistState] >> Alle Löschoperationen für clearWishlist eingeleitet.")
    }

    private func addProduct(product: WooCommerceProduct, idForWishlist: Int) {
        guard !wishlistProductIds.contains(idForWishlist) else { return }
        wishlistProductIds.insert(idForWishlist)
        if !_wishlistProducts.contains(where: { (($0.parent_id ?? 0) > 0 ? $0.parent_id! : $0.id) == idForWishlist }) {
            _wishlistProducts.insert(product, at: 0)
        }
        Task(priority: .background) {
            if authManager.isLoggedIn {
                let variationId = (product.parent_id ?? 0) > 0 ? product.id : nil
                do {
                    _ = try await addToWishlistAPI(productId: idForWishlist, variationId: variationId)
                } catch {
                    await MainActor.run { removeProductFromLocalState(productId: idForWishlist) }
                }
            } else {
                saveGuestWishlist()
            }
        }
    }
    
    private func removeProduct(productId: Int) {
        let originalProducts = self._wishlistProducts
        removeProductFromLocalState(productId: productId)
        Task(priority: .background) {
            if authManager.isLoggedIn {
                do {
                    _ = try await removeFromWishlistAPI(productId: productId, variationId: nil)
                } catch {
                    await MainActor.run {
                        self.wishlistProductIds.insert(productId)
                        self._wishlistProducts = originalProducts
                    }
                }
            } else {
                saveGuestWishlist()
            }
        }
    }
    
    // Alle weiteren Funktionen (sortProducts, removeProductFromLocalState, etc.) bleiben unverändert.
    private func sortProducts(_ products: [WooCommerceProduct]) -> [WooCommerceProduct] {
        switch sortOption {
            case .dateAdded:
            return products;
            case .priceAscending:
            return products.sorted { Double($0.price) ?? 0.0 < Double($1.price) ?? 0.0 };
            case .priceDescending:
            return products.sorted { Double($0.price) ?? 0.0 > Double($1.price) ?? 0.0 };
            case .nameAscending:
            return products.sorted { $0.name.lowercased() < $1.name.lowercased() } } }
    private func removeProductFromLocalState(productId: Int) { wishlistProductIds.remove(productId); _wishlistProducts.removeAll { product
        in let idToRemove = (product.parent_id ?? 0) > 0 ? product.parent_id! : product.id;
        return idToRemove == productId } }
    func fetchWishlistFromServer()
    async {
        guard authManager.isLoggedIn, !isLoading
        else { return }; isLoading = true; errorMessage = nil; do { let wishlistResponse = try await performWishlistRequest(endpoint: wishlistAPI.wishlist, method: "GET", decodingType: YGEWishlist.self);
            let serverIDs = Set(wishlistResponse.items.map { $0.productId });
            if serverIDs != self.wishlistProductIds { self.wishlistProductIds = serverIDs; await fetchFullProducts() } } catch { self.errorMessage = "Ihre Wunschliste konnte nicht geladen werden."; self._wishlistProducts.removeAll(); self.wishlistProductIds.removeAll() }; isLoading = false }
    private func observeAuthenticationChanges() { authManager.$isLoggedIn.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] isLoggedIn in Task { await self?.handleAuthChange(isLoggedIn: isLoggedIn) } }.store(in: &cancellables) }
    private func handleAuthChange(isLoggedIn: Bool)
    async { fetchProductsTask?.cancel(); self.wishlistProductIds.removeAll(); self._wishlistProducts.removeAll();
        if isLoggedIn {
            let guestIDs = UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? []; UserDefaults.standard.removeObject(forKey: guestWishlistKey);
            await fetchWishlistFromServer();
            let missingIDs = guestIDs.filter { !self.wishlistProductIds.contains($0) };
            if !missingIDs.isEmpty {
                for productId in missingIDs { Task(priority: .background) { _ = try? await self.addToWishlistAPI(productId: productId, variationId: nil) } }; self.wishlistProductIds.formUnion(missingIDs); await fetchFullProducts() } } else { loadGuestWishlist() } }
    private func addToWishlistAPI(productId: Int, variationId: Int?) async throws -> YGEWishlist {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]; return try await performWishlistRequest(endpoint: wishlistAPI.addToWishlist, method: "POST", body: body, decodingType: YGEWishlist.self) }
    private func removeFromWishlistAPI(productId: Int, variationId: Int?) async throws -> YGEWishlist {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId];
        return try await performWishlistRequest(endpoint: wishlistAPI.removeFromWishlist, method: "POST", body: body, decodingType: YGEWishlist.self) }
    private func performWishlistRequest<T: Decodable>(endpoint: String, method: String, body: [String: Any?]? = nil, decodingType: T.Type)
    async throws -> T { guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }; var request = URLRequest(url: url); request.httpMethod = method; if let token = authManager.getAuthToken() { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }; if let body = body { request.setValue("application/json", forHTTPHeaderField: "Content-Type"); request.httpBody = try? JSONSerialization.data(withJSONObject: body.compactMapValues { $0 }) }; let (data, response) = try await URLSession.shared.data(for: request); guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else { let errorData = String(data: data, encoding: .utf8) ?? "No error data"; print("[API ERROR] Status: \((response as? HTTPURLResponse)?.statusCode ?? 500), Data: \(errorData)"); throw WooCommerceAPIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: "Wishlist API Error", errorCode: nil) }; return try JSONDecoder().decode(T.self, from: data) }
    private func fetchFullProducts() async { fetchProductsTask?.cancel();
        let idsToFetch = Array(wishlistProductIds);
        guard !idsToFetch.isEmpty else { self._wishlistProducts = []; return }; self.fetchProductsTask = Task { do { var params = ProductFilterParameters(); params.include = idsToFetch;
        let responseContainer = try await wcApi.fetchProducts(params: params);
        if !Task.isCancelled { let productMap = Dictionary(uniqueKeysWithValues: responseContainer.products.map { ($0.id, $0) }); self._wishlistProducts = idsToFetch.compactMap { productMap[$0] } } } catch {
        if !Task.isCancelled { self.errorMessage = "Produktdetails der Wunschliste konnten nicht geladen werden." } } };
        await self.fetchProductsTask?.value }
    private func loadGuestWishlist() {
        let guestIDs = UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? []; self.wishlistProductIds = Set(guestIDs); Task {
            await fetchFullProducts() } }
    private func saveGuestWishlist() { UserDefaults.standard.set(Array(self.wishlistProductIds), forKey: guestWishlistKey) }
}
