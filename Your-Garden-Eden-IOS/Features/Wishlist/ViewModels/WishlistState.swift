//
//  WishlistState.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 29.05.25.
//


// Core/Wishlist/WishlistState.swift (Neuer Ordner/Datei, oder wo du globale States ablegst)
import Foundation
import Combine
import SwiftUI // Für @MainActor

@MainActor
class WishlistState: ObservableObject {
    @Published private(set) var wishlistProductIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var authManager: FirebaseAuthManager
    private var firestoreManager: FirestoreManager
    private var cancellables = Set<AnyCancellable>()

    init(authManager: FirebaseAuthManager = .shared, firestoreManager: FirestoreManager = .shared) {
        self.authManager = authManager
        self.firestoreManager = firestoreManager
        print("WishlistState initialized.")

        // Beobachte Änderungen im Benutzerstatus des FirebaseAuthManager
        authManager.$user
            .receive(on: DispatchQueue.main) // Stelle sicher, dass es auf dem Main Thread passiert
            .sink { [weak self] firebaseUser in
                guard let self = self else { return }
                if let user = firebaseUser {
                    print("WishlistState: User logged in (\(user.id)), loading wishlist.")
                    self.loadWishlist(userId: user.id)
                } else {
                    print("WishlistState: User logged out, clearing wishlist.")
                    self.wishlistProductIds = [] // Wunschliste leeren, wenn Benutzer ausgeloggt ist
                    self.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }

    private func loadWishlist(userId: String) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let ids = try await firestoreManager.getWishlistProductIds(userId: userId)
                self.wishlistProductIds = Set(ids)
                print("WishlistState: Loaded \(self.wishlistProductIds.count) items into wishlist state.")
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Fehler beim Laden der Wunschliste."
                print("WishlistState: Error loading wishlist: \(error)")
            }
            isLoading = false
        }
    }

    func addProductToWishlist(productId: Int) {
        guard let userId = authManager.user?.id else {
            errorMessage = WishlistError.notAuthenticated.errorDescription
            print("WishlistState: Cannot add to wishlist, user not authenticated.")
            // Optional: Zeige hier eine Aufforderung zum Login (z.B. über einen weiteren @Published-State)
            return
        }
        guard !wishlistProductIds.contains(productId) else {
            print("WishlistState: Product \(productId) is already in wishlist.")
            return // Produkt ist bereits drin
        }

        isLoading = true; errorMessage = nil
        Task {
            do {
                try await firestoreManager.addToWishlist(userId: userId, productId: productId)
                wishlistProductIds.insert(productId) // Optimistisches Update der UI
                print("WishlistState: Product \(productId) added. Wishlist count: \(wishlistProductIds.count)")
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Fehler beim Hinzufügen zur Wunschliste."
                print("WishlistState: Error adding product \(productId) to wishlist: \(error)")
                // Optional: Rollback des UI-Updates, falls das Backend fehlschlägt (hier nicht implementiert)
            }
            isLoading = false
        }
    }

    func removeProductFromWishlist(productId: Int) {
        guard let userId = authManager.user?.id else {
            errorMessage = WishlistError.notAuthenticated.errorDescription
            print("WishlistState: Cannot remove from wishlist, user not authenticated.")
            return
        }
        guard wishlistProductIds.contains(productId) else {
            print("WishlistState: Product \(productId) is not in wishlist to remove.")
            return // Produkt ist nicht drin
        }
        
        isLoading = true; errorMessage = nil
        Task {
            do {
                try await firestoreManager.removeFromWishlist(userId: userId, productId: productId)
                wishlistProductIds.remove(productId) // Optimistisches Update
                print("WishlistState: Product \(productId) removed. Wishlist count: \(wishlistProductIds.count)")
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Fehler beim Entfernen von der Wunschliste."
                print("WishlistState: Error removing product \(productId) from wishlist: \(error)")
            }
            isLoading = false
        }
    }

    func isProductInWishlist(productId: Int) -> Bool {
        return wishlistProductIds.contains(productId)
    }

    // Funktion zum Umschalten des Wunschlistenstatus
    func toggleWishlistStatus(for productId: Int) {
        if isProductInWishlist(productId: productId) {
            removeProductFromWishlist(productId: productId)
        } else {
            addProductToWishlist(productId: productId)
        }
    }
}