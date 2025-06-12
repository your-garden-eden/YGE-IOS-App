// Features/Wishlist/State/WishlistState.swift

import Foundation
import Combine

@MainActor
final class WishlistState: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var wishlistProductIds: Set<Int> = []
    @Published private(set) var wishlistProducts: [WooCommerceProduct] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let authManager: AuthManager
    private let wcApiService = WooCommerceAPIManager.shared
    private var cancellables = Set<AnyCancellable>()

    init(authManager: AuthManager) {
        self.authManager = authManager
        print("✅ WishlistState initialized.")
        observeAuthenticationChanges()
    }

    private func observeAuthenticationChanges() {
        authManager.$isLoggedIn
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
                    self?.fetchWishlistFromServer()
                } else {
                    self?.wishlistProductIds.removeAll()
                    self?.wishlistProducts.removeAll()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    
    func isProductInWishlist(productId: Int) -> Bool {
        return wishlistProductIds.contains(productId)
    }
    
    func toggleWishlistStatus(for product: WooCommerceProduct) {
        let parentProductId = product.parentId == 0 ? product.id : product.parentId
        
        if isProductInWishlist(productId: parentProductId) {
             let variationId = product.parentId != 0 ? product.id : nil
             removeProduct(productId: parentProductId, variationId: variationId)
        } else {
             addProduct(product: product)
        }
    }
    
    // MARK: - API Logic
    
    private func fetchWishlistFromServer() {
        Task {
            guard authManager.isLoggedIn else { return }
            print("▶️ Fetching user wishlist from server...")
            self.isLoading = true
            do {
                let wishlistResponse = try await wcApiService.fetchUserWishlist()
                let serverIDs = wishlistResponse.items.map { $0.productId }
                self.wishlistProductIds = Set(serverIDs)
                print("✅ Successfully fetched \(serverIDs.count) wishlist item IDs.")
                await fetchWishlistProducts()
            } catch {
                self.errorMessage = "Ihre Wunschliste konnte nicht geladen werden."
                print("🔴 Error fetching wishlist: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }

    func fetchWishlistProducts() async {
        let idsToFetch = Array(wishlistProductIds)
        guard !idsToFetch.isEmpty else {
            self.wishlistProducts = []
            return
        }
        self.isLoading = true
        do {
            let responseContainer = try await wcApiService.fetchProducts(include: idsToFetch)
            self.wishlistProducts = responseContainer.products
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Fehler beim Laden der Wunschlisten-Produkte."
        }
        self.isLoading = false
    }

    private func addProduct(product: WooCommerceProduct) {
        let parentId = product.parentId == 0 ? product.id : product.parentId
        let variationId = product.parentId != 0 ? product.id : nil

        guard !wishlistProductIds.contains(parentId) else { return }
        
        wishlistProductIds.insert(parentId)
        wishlistProducts.insert(product, at: 0)
        
        Task(priority: .background) {
            // KORREKTUR: Sende nur dann an den Server, wenn der Benutzer eingeloggt ist.
            guard authManager.isLoggedIn else {
                print("ⓘ User is a guest. Wishlist change is local only.")
                return
            }
            
            do {
                try await wcApiService.addToUserWishlist(productId: parentId, variationId: variationId)
                print("✅ Product \(parentId) added to server wishlist.")
            } catch {
                print("🔴 Failed to add product \(parentId) to server wishlist: \(error.localizedDescription)")
            }
        }
    }

    private func removeProduct(productId: Int, variationId: Int?) {
        wishlistProductIds.remove(productId)
        wishlistProducts.removeAll { ($0.parentId == 0 ? $0.id : $0.parentId) == productId }
        
        Task(priority: .background) {
            // KORREKTUR: Sende nur dann an den Server, wenn der Benutzer eingeloggt ist.
            guard authManager.isLoggedIn else {
                print("ⓘ User is a guest. Wishlist change is local only.")
                return
            }
            
            do {
                try await wcApiService.removeFromUserWishlist(productId: productId, variationId: variationId)
                print("✅ Product \(productId) removed from server wishlist.")
            } catch {
                print("🔴 Failed to remove product \(productId) from server wishlist: \(error.localizedDescription)")
            }
        }
    }
}
