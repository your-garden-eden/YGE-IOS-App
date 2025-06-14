// Path: Your-Garden-Eden-IOS/Core/Service/WishlistState.swift

import Foundation
import Combine

@MainActor
final class WishlistState: ObservableObject {
    
    @Published private(set) var wishlistProductIds: Set<Int> = []
    @Published private(set) var wishlistProducts: [WooCommerceProduct] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authManager = AuthManager.shared
    private let wcApiService = WooCommerceAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var fetchProductsTask: Task<Void, Never>?
    
    private let guestWishlistKey = "guestWishlistProductIDs_v2"

    init() {
        print("✅ WishlistState initialized.")
        observeAuthenticationChanges()
        
        if !authManager.isLoggedIn {
            loadGuestWishlist()
        } else {
            Task { await fetchWishlistFromServer() }
        }
    }

    // MARK: - Public API
    func isProductInWishlist(productId: Int) -> Bool {
        wishlistProductIds.contains(productId)
    }
    
    func toggleWishlistStatus(for product: WooCommerceProduct) {
        let parentProductId = product.parentId == 0 ? product.id : product.parentId
        
        if isProductInWishlist(productId: parentProductId) {
             removeProduct(productId: parentProductId)
        } else {
             addProduct(product: product)
        }
    }
    
    func fetchWishlistFromServer() async {
        guard authManager.isLoggedIn, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let wishlistResponse = try await wcApiService.fetchUserWishlist()
            let serverIDs = Set(wishlistResponse.items.map { $0.productId })
            
            if serverIDs != self.wishlistProductIds {
                self.wishlistProductIds = serverIDs
                await fetchFullProducts()
            }
        } catch {
            self.errorMessage = "Ihre Wunschliste konnte nicht geladen werden."
            self.wishlistProducts.removeAll()
            self.wishlistProductIds.removeAll()
        }
        
        isLoading = false
    }

    // MARK: - Private Core Logic
    private func observeAuthenticationChanges() {
        authManager.$isLoggedIn
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                Task { await self?.handleAuthChange(isLoggedIn: isLoggedIn) }
            }
            .store(in: &cancellables)
    }
    
    private func handleAuthChange(isLoggedIn: Bool) async {
        fetchProductsTask?.cancel()
        self.wishlistProductIds.removeAll()
        self.wishlistProducts.removeAll()
        
        if isLoggedIn {
            let guestIDs = UserDefaults.standard.array(forKey: guestWishlistKey) as? [Int] ?? []
            UserDefaults.standard.removeObject(forKey: guestWishlistKey)

            await fetchWishlistFromServer()
            
            let serverIDs = self.wishlistProductIds
            let missingIDs = guestIDs.filter { !serverIDs.contains($0) }
            
            if !missingIDs.isEmpty {
                print("🔵 WishlistState: Merging \(missingIDs.count) guest items with server wishlist.")
                for productId in missingIDs {
                    Task(priority: .background) { try? await self.wcApiService.addToUserWishlist(productId: productId, variationId: nil) }
                }
                self.wishlistProductIds.formUnion(missingIDs)
                await fetchFullProducts()
            }
        } else {
            loadGuestWishlist()
        }
    }

    private func addProduct(product: WooCommerceProduct) {
        let parentId = product.parentId == 0 ? product.id : product.parentId
        guard !wishlistProductIds.contains(parentId) else { return }
        
        wishlistProductIds.insert(parentId)
        if !wishlistProducts.contains(where: { ($0.id) == parentId }) {
            wishlistProducts.insert(product, at: 0)
        }
        
        Task(priority: .background) {
            if authManager.isLoggedIn {
                let variationId = product.parentId != 0 ? product.id : nil
                do { try await wcApiService.addToUserWishlist(productId: parentId, variationId: variationId) }
                catch { await MainActor.run { removeProductFromLocalState(productId: parentId) } }
            } else { saveGuestWishlist() }
        }
    }
    
    private func removeProduct(productId: Int) {
        let originalProducts = self.wishlistProducts
        removeProductFromLocalState(productId: productId)
        
        Task(priority: .background) {
            if authManager.isLoggedIn {
                do { try await wcApiService.removeFromUserWishlist(productId: productId, variationId: nil) }
                catch {
                    await MainActor.run {
                        self.wishlistProductIds.insert(productId)
                        self.wishlistProducts = originalProducts
                    }
                }
            } else { saveGuestWishlist() }
        }
    }
    
    // MARK: - Helper Functions
    private func fetchFullProducts() async {
        fetchProductsTask?.cancel()
        let idsToFetch = Array(wishlistProductIds)
        guard !idsToFetch.isEmpty else {
            self.wishlistProducts = []
            return
        }
        
        self.fetchProductsTask = Task {
            do {
                let responseContainer = try await wcApiService.fetchProducts(include: idsToFetch)
                if !Task.isCancelled { self.wishlistProducts = responseContainer.products }
            } catch {
                if !Task.isCancelled { self.errorMessage = "Produktdetails der Wunschliste konnten nicht geladen werden." }
            }
        }
        await self.fetchProductsTask?.value
    }

    private func removeProductFromLocalState(productId: Int) {
        wishlistProductIds.remove(productId)
        wishlistProducts.removeAll { ($0.parentId == 0 ? $0.id : $0.parentId) == productId }
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
