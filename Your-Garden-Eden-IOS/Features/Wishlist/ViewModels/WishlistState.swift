import Foundation
import Combine
import SwiftUI

@MainActor
class WishlistState: ObservableObject {
    @Published private(set) var wishlistProductIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var authManager: FirebaseAuthManager
    private var firestoreManager: FirestoreManager
    private var cancellables = Set<AnyCancellable>()

    private let localWishlistKey = "localUserWishlistProductIDs"

    init(authManager: FirebaseAuthManager = .shared, firestoreManager: FirestoreManager = .shared) {
        self.authManager = authManager
        self.firestoreManager = firestoreManager
        print("🤍 WishlistState initialized.")

        authManager.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firebaseUser in
                guard let self = self else { return }
                Task {
                    if let user = firebaseUser {
                        print("🤍 WishlistState: User logged in (\(user.id)). Transitioning wishlist.")
                        await self.transitionToOnlineWishlist(userId: user.id)
                    } else {
                        print("🤍 WishlistState: User logged out. Transitioning to local wishlist.")
                        self.loadLocalWishlist()
                        self.errorMessage = nil
                    }
                }
            }
            .store(in: &cancellables)

        if authManager.user == nil {
            loadLocalWishlist()
            print("🤍 WishlistState: Initial load - no user, loaded local wishlist.")
        }
    }

    // ... (loadLocalWishlist, saveLocalWishlist, clearLocalWishlist, loadOnlineWishlist bleiben unverändert) ...
    private func loadLocalWishlist() {
        isLoading = true; errorMessage = nil
        let storedIds = UserDefaults.standard.array(forKey: localWishlistKey) as? [Int] ?? []
        self.wishlistProductIds = Set(storedIds)
        print("🤍 WishlistState: Loaded \(self.wishlistProductIds.count) items from local wishlist.")
        isLoading = false
    }

    private func saveLocalWishlist() {
        UserDefaults.standard.set(Array(self.wishlistProductIds), forKey: localWishlistKey)
        print("🤍 WishlistState: Saved \(self.wishlistProductIds.count) items to local wishlist.")
    }

    private func clearLocalWishlist() {
        UserDefaults.standard.removeObject(forKey: localWishlistKey)
        print("🤍 WishlistState: Cleared local wishlist.")
    }
    
    private func loadOnlineWishlist(userId: String) async {
        isLoading = true; errorMessage = nil
        do {
            let ids = try await firestoreManager.getWishlistProductIds(userId: userId)
            self.wishlistProductIds = Set(ids)
            print("🤍 WishlistState: Loaded \(self.wishlistProductIds.count) items from Firestore for user \(userId).")
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Fehler beim Laden der Online-Wunschliste."
            print("🔴 WishlistState: Error loading online wishlist: \(error)")
        }
        isLoading = false
    }

    // MARK: - Übergangslogik
    private func transitionToOnlineWishlist(userId: String) async {
        isLoading = true; errorMessage = nil
        print("🔄 WishlistState: Starting transition to online for user \(userId)...")
        
        let localIdsSet = Set(UserDefaults.standard.array(forKey: localWishlistKey) as? [Int] ?? [])
        print("🔄 WishlistState: Found \(localIdsSet.count) items in local wishlist.")
        
        do {
            let onlineIdsSet = Set(try await firestoreManager.getWishlistProductIds(userId: userId))
            print("🔄 WishlistState: Found \(onlineIdsSet.count) items in online wishlist.")
            
            let mergedIds = localIdsSet.union(onlineIdsSet)
            print("🔄 WishlistState: Merged set has \(mergedIds.count) items.")
            self.wishlistProductIds = mergedIds
            
            let idsToAddOnline = localIdsSet.subtracting(onlineIdsSet)
            if !idsToAddOnline.isEmpty {
                print("🔄 WishlistState: Syncing \(idsToAddOnline.count) local-only items to Firestore...")
                // --- KORREKTUR: Wir verwenden eine Schleife, da 'addMultipleToWishlist' nicht existiert ---
                for productId in idsToAddOnline {
                    try await firestoreManager.addToWishlist(userId: userId, productId: productId)
                }
                print("🔄 WishlistState: Sync successful.")
            }
            
            clearLocalWishlist()
            
        } catch {
            self.errorMessage = "Fehler beim Synchronisieren der Wunschliste."
            print("🔴 WishlistState: Error during transition: \(error)")
        }
        
        isLoading = false
        print("🔄 WishlistState: Transition complete. Final count: \(self.wishlistProductIds.count).")
    }

    // ... (Der Rest der Datei: addProductToWishlist, removeProductFromWishlist, etc. bleibt unverändert) ...
    func addProductToWishlist(productId: Int) {
        guard !wishlistProductIds.contains(productId) else { return }
        isLoading = true; errorMessage = nil
        wishlistProductIds.insert(productId)

        if let userId = authManager.user?.id {
            Task {
                do {
                    try await firestoreManager.addToWishlist(userId: userId, productId: productId)
                } catch {
                    self.errorMessage = "Fehler beim Hinzufügen (Online)."
                    wishlistProductIds.remove(productId)
                }
                isLoading = false
            }
        } else {
            saveLocalWishlist()
            isLoading = false
        }
    }

    func removeProductFromWishlist(productId: Int) {
        guard wishlistProductIds.contains(productId) else { return }
        isLoading = true; errorMessage = nil
        let originalWishlist = wishlistProductIds
        wishlistProductIds.remove(productId)

        if let userId = authManager.user?.id {
            Task {
                do {
                    try await firestoreManager.removeFromWishlist(userId: userId, productId: productId)
                } catch {
                    self.errorMessage = "Fehler beim Entfernen (Online)."
                    wishlistProductIds = originalWishlist
                }
                isLoading = false
            }
        } else {
            saveLocalWishlist()
            isLoading = false
        }
    }

    func isProductInWishlist(productId: Int) -> Bool {
        return wishlistProductIds.contains(productId)
    }

    func toggleWishlistStatus(for productId: Int) {
        if isProductInWishlist(productId: productId) {
            removeProductFromWishlist(productId: productId)
        } else {
            addProductToWishlist(productId: productId)
        }
    }
}
