// Dateiname: WishlistState.swift

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

    // Hält den aktuellen Lade-Task, um Duplikate zu vermeiden.
    private var fetchProductsTask: Task<Void, Never>?

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
                // Bei Login/Logout die Wunschliste vom Server neu laden oder leeren.
                Task {
                    if isLoggedIn {
                        await self?.fetchWishlistFromServer()
                    } else {
                        self?.wishlistProductIds.removeAll()
                        self?.wishlistProducts.removeAll()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    
    func isProductInWishlist(productId: Int) -> Bool {
        // Berücksichtigt auch Varianten, indem es die parentId prüft, falls vorhanden.
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
    
    // MARK: - Autonome API-Logik
    
    func fetchWishlistFromServer() async {
        guard authManager.isLoggedIn, !isLoading else { return }
        
        print("▶️ Fetching user wishlist from server...")
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let wishlistResponse = try await wcApiService.fetchUserWishlist()
            let serverIDs = Set(wishlistResponse.items.map { $0.productId })
            print("✅ Successfully fetched \(serverIDs.count) wishlist item IDs.")
            
            // Nur wenn sich die IDs geändert haben, die Produkte neu laden.
            if serverIDs != self.wishlistProductIds {
                self.wishlistProductIds = serverIDs
                await fetchWishlistProducts()
            }
        } catch {
            self.errorMessage = "Ihre Wunschliste konnte nicht geladen werden."
            print("🔴 Error fetching wishlist: \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }

    private func fetchWishlistProducts() async {
        // Bricht den laufenden Task ab, falls ein neuer gestartet wird.
        fetchProductsTask?.cancel()
        
        let idsToFetch = Array(wishlistProductIds)
        
        // Wenn keine IDs da sind, leeren wir die Produktliste.
        guard !idsToFetch.isEmpty else {
            if !wishlistProducts.isEmpty { self.wishlistProducts = [] }
            return
        }

        self.fetchProductsTask = Task {
            do {
                let responseContainer = try await wcApiService.fetchProducts(include: idsToFetch)
                // Prüft, ob der Task in der Zwischenzeit abgebrochen wurde.
                try Task.checkCancellation()
                self.wishlistProducts = responseContainer.products
                self.errorMessage = nil
            } catch is CancellationError {
                print("ⓘ Wishlist product fetch was cancelled.")
            } catch {
                self.errorMessage = "Fehler beim Laden der Wunschlisten-Produkte."
                print("🔴 Error fetching wishlist products: \(error.localizedDescription)")
            }
        }
        await self.fetchProductsTask?.value
    }

    private func addProduct(product: WooCommerceProduct) {
        let parentId = product.parentId == 0 ? product.id : product.parentId
        guard !wishlistProductIds.contains(parentId) else { return }
        
        // UI sofort aktualisieren
        wishlistProductIds.insert(parentId)
        if !wishlistProducts.contains(where: { $0.id == product.id }) {
            wishlistProducts.insert(product, at: 0)
        }
        
        Task(priority: .background) {
            guard authManager.isLoggedIn else { return }
            do {
                let variationId = product.parentId != 0 ? product.id : nil
                try await wcApiService.addToUserWishlist(productId: parentId, variationId: variationId)
                print("✅ Product \(parentId) added to server wishlist.")
            } catch {
                print("🔴 Failed to add product \(parentId) to server wishlist: \(error.localizedDescription)")
                // Optional: UI zurücksetzen, falls der Server-Call fehlschlägt
                await MainActor.run {
                    self.wishlistProductIds.remove(parentId)
                    self.wishlistProducts.removeAll { $0.id == product.id }
                }
            }
        }
    }

    private func removeProduct(productId: Int, variationId: Int?) {
        let originalProducts = self.wishlistProducts
        
        // UI sofort aktualisieren
        wishlistProductIds.remove(productId)
        wishlistProducts.removeAll { ($0.parentId == 0 ? $0.id : $0.parentId) == productId }
        
        Task(priority: .background) {
            guard authManager.isLoggedIn else { return }
            do {
                try await wcApiService.removeFromUserWishlist(productId: productId, variationId: variationId)
                print("✅ Product \(productId) removed from server wishlist.")
            } catch {
                print("🔴 Failed to remove product \(productId) from server wishlist: \(error.localizedDescription)")
                // Optional: UI zurücksetzen, falls der Server-Call fehlschlägt
                await MainActor.run {
                    self.wishlistProductIds.insert(productId)
                    self.wishlistProducts = originalProducts
                }
            }
        }
    }
}
