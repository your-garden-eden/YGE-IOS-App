// Core/Wishlist/WishlistState.swift
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

    private let localWishlistKey = "localUserWishlistProductIDs" // Key für UserDefaults

    init(authManager: FirebaseAuthManager = .shared, firestoreManager: FirestoreManager = .shared) {
        self.authManager = authManager
        self.firestoreManager = firestoreManager
        print("WishlistState initialized.")

        authManager.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firebaseUser in
                guard let self = self else { return }
                Task { // Mache den gesamten Block asynchron, um UI-Blockaden zu vermeiden
                    if let user = firebaseUser {
                        print("WishlistState: User logged in (\(user.id)). Transitioning wishlist.")
                        await self.transitionToOnlineWishlist(userId: user.id)
                    } else {
                        print("WishlistState: User logged out. Transitioning to local wishlist.")
                        self.loadLocalWishlist() // Beim Ausloggen die lokale Liste laden
                        self.errorMessage = nil // Fehler zurücksetzen
                    }
                }
            }
            .store(in: &cancellables)

        // Beim Start der App prüfen, ob ein Benutzer angemeldet ist oder die lokale Liste geladen werden soll
        if authManager.user == nil {
            loadLocalWishlist()
            print("WishlistState: Initial load - no user, loaded local wishlist.")
        }
        // Wenn ein User bereits da ist, wird der Sink-Block oben das Laden der Online-Liste triggern.
    }

    // MARK: - Lokale Wunschlisten-Operationen (UserDefaults)
    private func loadLocalWishlist() {
        isLoading = true; errorMessage = nil
        let storedIds = UserDefaults.standard.array(forKey: localWishlistKey) as? [Int] ?? []
        self.wishlistProductIds = Set(storedIds)
        print("WishlistState: Loaded \(self.wishlistProductIds.count) items from local (UserDefaults) wishlist.")
        isLoading = false
    }

    private func saveLocalWishlist() {
        UserDefaults.standard.set(Array(self.wishlistProductIds), forKey: localWishlistKey)
        print("WishlistState: Saved \(self.wishlistProductIds.count) items to local (UserDefaults) wishlist.")
    }

    private func clearLocalWishlist() {
        UserDefaults.standard.removeObject(forKey: localWishlistKey)
        print("WishlistState: Cleared local (UserDefaults) wishlist.")
    }

    // MARK: - Online Wunschlisten-Operationen (Firestore)
    private func loadOnlineWishlist(userId: String) async {
        isLoading = true; errorMessage = nil
        do {
            let ids = try await firestoreManager.getWishlistProductIds(userId: userId)
            self.wishlistProductIds = Set(ids)
            print("WishlistState: Loaded \(self.wishlistProductIds.count) items from online (Firestore) wishlist for user \(userId).")
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Fehler beim Laden der Online-Wunschliste."
            print("WishlistState: Error loading online wishlist: \(error)")
        }
        isLoading = false
    }

    // MARK: - Übergangslogik
    private func transitionToOnlineWishlist(userId: String) async {
        isLoading = true; errorMessage = nil
        print("WishlistState: Transitioning to online wishlist for user \(userId).")

        // 1. Lokale Wunschliste auslesen
        let localIdsArray = UserDefaults.standard.array(forKey: localWishlistKey) as? [Int] ?? []
        let localIdsSet = Set(localIdsArray)
        print("WishlistState: Found \(localIdsSet.count) items in local wishlist during transition.")

        // 2. Online Wunschliste auslesen
        var onlineIdsSet: Set<Int>
        do {
            onlineIdsSet = Set(try await firestoreManager.getWishlistProductIds(userId: userId))
            print("WishlistState: Found \(onlineIdsSet.count) items in online wishlist during transition.")
        } catch {
            self.errorMessage = "Fehler beim Abrufen der Online-Wunschliste für den Übergang."
            print("WishlistState: Error fetching online wishlist for transition: \(error)")
            isLoading = false
            // Fallback: Nur lokale Liste verwenden, wenn Online-Abruf fehlschlägt? Oder Fehler anzeigen?
            // Fürs Erste behalten wir die zuletzt geladene (potenziell lokale) Liste.
            return
        }

        // 3. Zusammenführen (Merge): Alle IDs aus beiden Listen nehmen
        let mergedIds = localIdsSet.union(onlineIdsSet)
        print("WishlistState: Merged wishlist has \(mergedIds.count) items.")

        // 4. UI sofort mit den zusammengeführten IDs aktualisieren (optimistisch)
        self.wishlistProductIds = mergedIds

        // 5. Zusammengeführte Liste in Firestore speichern (nur wenn Änderungen nötig sind)
        // Wir müssen die Produkte, die nur lokal waren, zu Firestore hinzufügen.
        // Produkte, die nur online waren, bleiben. Produkte in beiden bleiben.
        let idsToAddOnline = localIdsSet.subtracting(onlineIdsSet) // IDs, die nur lokal waren

        if !idsToAddOnline.isEmpty {
            print("WishlistState: \(idsToAddOnline.count) local-only items will be added to Firestore.")
            // Hier könnten wir die Items einzeln oder in einer Batch zu Firestore hinzufügen.
            // Für Einfachheit fügen wir sie einzeln hinzu.
            var anyErrorOccurred = false
            for productId in idsToAddOnline {
                do {
                    try await firestoreManager.addToWishlist(userId: userId, productId: productId)
                } catch {
                    print("WishlistState: Error adding product \(productId) from local to online wishlist: \(error)")
                    // Selbst wenn ein Fehler auftritt, ist die ID bereits im UI-State.
                    // Man könnte hier komplexere Fehlerbehandlung / Rollback machen.
                    anyErrorOccurred = true
                }
            }
            if anyErrorOccurred {
                self.errorMessage = "Einige lokale Wunschlisten-Items konnten nicht synchronisiert werden."
            } else {
                 print("WishlistState: Successfully synced local-only items to Firestore.")
            }
        } else {
            print("WishlistState: No new local-only items to sync to Firestore.")
        }
        
        // 6. (Optional) Lokale Wunschliste nach erfolgreichem Merge leeren
        clearLocalWishlist()
        isLoading = false
        print("WishlistState: Transition to online wishlist complete. Current state has \(self.wishlistProductIds.count) items.")
    }


    // MARK: - Öffentliche Methoden zum Modifizieren der Wunschliste
    func addProductToWishlist(productId: Int) {
        guard !wishlistProductIds.contains(productId) else {
            print("WishlistState: Product \(productId) is already in wishlist (UI state).")
            return
        }

        isLoading = true; errorMessage = nil
        wishlistProductIds.insert(productId) // Optimistisches UI-Update

        if let userId = authManager.user?.id { // Angemeldeter Benutzer
            Task {
                do {
                    try await firestoreManager.addToWishlist(userId: userId, productId: productId)
                    print("WishlistState (Online): Product \(productId) added. Wishlist count: \(wishlistProductIds.count)")
                } catch {
                    self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Fehler beim Hinzufügen (Online)."
                    print("WishlistState (Online): Error adding product \(productId): \(error)")
                    wishlistProductIds.remove(productId) // Rollback UI-Update bei Fehler
                }
                isLoading = false
            }
        } else { // Nicht angemeldeter Benutzer
            saveLocalWishlist()
            print("WishlistState (Local): Product \(productId) added. Wishlist count: \(wishlistProductIds.count)")
            isLoading = false
        }
    }

    func removeProductFromWishlist(productId: Int) {
        guard wishlistProductIds.contains(productId) else {
            print("WishlistState: Product \(productId) is not in wishlist (UI state) to remove.")
            return
        }

        isLoading = true; errorMessage = nil
        let originalWishlist = wishlistProductIds // Für potenziellen Rollback
        wishlistProductIds.remove(productId) // Optimistisches UI-Update

        if let userId = authManager.user?.id { // Angemeldeter Benutzer
            Task {
                do {
                    try await firestoreManager.removeFromWishlist(userId: userId, productId: productId)
                    print("WishlistState (Online): Product \(productId) removed. Wishlist count: \(wishlistProductIds.count)")
                } catch {
                    self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "Fehler beim Entfernen (Online)."
                    print("WishlistState (Online): Error removing product \(productId): \(error)")
                    wishlistProductIds = originalWishlist // Rollback UI-Update
                }
                isLoading = false
            }
        } else { // Nicht angemeldeter Benutzer
            saveLocalWishlist()
            print("WishlistState (Local): Product \(productId) removed. Wishlist count: \(wishlistProductIds.count)")
            isLoading = false
        }
    }

    func isProductInWishlist(productId: Int) -> Bool {
        return wishlistProductIds.contains(productId)
    }

    func toggleWishlistStatus(for productId: Int) {
        // Für nicht angemeldete Benutzer ist keine Login-Aufforderung direkt hier nötig,
        // da die Herz-Buttons in den Views das bei Bedarf handhaben können (oder auch nicht, wenn lokale Speicherung okay ist).
        // Die Methoden add/remove prüfen bereits auf `authManager.user`.
        // Wenn ein nicht-angemeldeter Nutzer das Herz klickt, wird es lokal gespeichert.
        // Wenn ein angemeldeter Nutzer klickt, wird es in Firestore gespeichert.
        // Die Notwendigkeit eines Login-Popups beim Klick auf das Herz, auch wenn lokal gespeichert wird,
        // ist eine UX-Entscheidung. Hier behandeln wir es so, dass der Klick immer funktioniert (lokal oder online).
        
        if isProductInWishlist(productId: productId) {
            removeProductFromWishlist(productId: productId)
        } else {
            addProductToWishlist(productId: productId)
        }
    }
}
