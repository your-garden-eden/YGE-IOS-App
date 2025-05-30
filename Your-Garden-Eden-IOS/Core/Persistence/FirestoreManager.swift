// Core/Persistence/FirestoreManager.swift
import Foundation
import FirebaseFirestore
import FirebaseFirestore // Für Codable-Support mit Firestore, falls du später komplexere Wishlist-Items speicherst

// Enum für spezifische Wishlist-Fehler (optional, aber gute Praxis)
enum WishlistError: Error, LocalizedError {
    case notAuthenticated
    case firestoreError(Error)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Benutzer nicht angemeldet. Bitte anmelden, um die Wunschliste zu nutzen."
        case .firestoreError(let err):
            return "Firestore-Fehler: \(err.localizedDescription)"
        case .unknownError:
            return "Ein unbekannter Fehler ist bei der Wunschliste aufgetreten."
        }
    }
}

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - WISHLIST Operations (Async/Await)

    /// Fügt ein Produkt zur Wunschliste des Benutzers hinzu.
    func addToWishlist(userId: String, productId: Int) async throws {
        // Wir speichern nur die Produkt-ID und ein Timestamp.
        // Das Dokument wird nach der Produkt-ID benannt, um einfaches Prüfen/Entfernen zu ermöglichen.
        let wishlistItemData = ["productId": productId, "addedAt": Timestamp()] as [String: Any]
        let documentRef = db.collection("users").document(userId).collection("wishlist").document("\(productId)")
        
        do {
            try await documentRef.setData(wishlistItemData)
            print("FirestoreManager: Product \(productId) added to wishlist for user \(userId).")
        } catch {
            print("FirestoreManager: Error adding product \(productId) to wishlist for user \(userId): \(error)")
            throw WishlistError.firestoreError(error)
        }
    }

    /// Entfernt ein Produkt von der Wunschliste des Benutzers.
    func removeFromWishlist(userId: String, productId: Int) async throws {
        let documentRef = db.collection("users").document(userId).collection("wishlist").document("\(productId)")
        
        do {
            try await documentRef.delete()
            print("FirestoreManager: Product \(productId) removed from wishlist for user \(userId).")
        } catch {
            print("FirestoreManager: Error removing product \(productId) from wishlist for user \(userId): \(error)")
            throw WishlistError.firestoreError(error)
        }
    }

    /// Ruft alle Produkt-IDs von der Wunschliste eines Benutzers ab.
    func getWishlistProductIds(userId: String) async throws -> [Int] {
        let collectionRef = db.collection("users").document(userId).collection("wishlist")
        
        do {
            let snapshot = try await collectionRef.getDocuments()
            let productIds = snapshot.documents.compactMap { $0.data()["productId"] as? Int }
            print("FirestoreManager: Fetched \(productIds.count) product IDs from wishlist for user \(userId).")
            return productIds
        } catch {
            print("FirestoreManager: Error fetching wishlist product IDs for user \(userId): \(error)")
            throw WishlistError.firestoreError(error)
        }
    }

    /// Überprüft, ob ein spezifisches Produkt auf der Wunschliste des Benutzers ist.
    func isProductInWishlist(userId: String, productId: Int) async throws -> Bool {
        let documentRef = db.collection("users").document(userId).collection("wishlist").document("\(productId)")
        
        do {
            let documentSnapshot = try await documentRef.getDocument()
            let exists = documentSnapshot.exists
            // print("FirestoreManager: Product \(productId) in wishlist for user \(userId): \(exists).") // Kann sehr gesprächig sein
            return exists
        } catch {
            // Wenn ein Fehler auftritt (z.B. Netzwerk), könnten wir false zurückgeben oder den Fehler werfen.
            // Hier werfen wir den Fehler, damit die aufrufende Stelle entscheiden kann.
            print("FirestoreManager: Error checking if product \(productId) is in wishlist for user \(userId): \(error)")
            throw WishlistError.firestoreError(error)
        }
    }
}
