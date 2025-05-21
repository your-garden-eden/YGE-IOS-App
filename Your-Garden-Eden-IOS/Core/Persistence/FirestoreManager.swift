import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    private init() {}

    // --- WISHLIST ---
    // func addToWishlist(userId: String, productId: Int, completion: @escaping (Error?) -> Void) {
    //     let wishlistItem = ["productId": productId, "addedAt": Timestamp()] as [String : Any]
    //     db.collection("users").document(userId).collection("wishlist").document("\(productId)").setData(wishlistItem) { error in
    //         completion(error)
    //     }
    // }

    // func removeFromWishlist(userId: String, productId: Int, completion: @escaping (Error?) -> Void) {
    //     db.collection("users").document(userId).collection("wishlist").document("\(productId)").delete { error in
    //         completion(error)
    //     }
    // }

    // func getWishlist(userId: String, completion: @escaping (Result<[Int], Error>) -> Void) { // Gibt Produkt-IDs zurück
    //     db.collection("users").document(userId).collection("wishlist").getDocuments { snapshot, error in
    //         if let error = error {
    //             completion(.failure(error))
    //             return
    //         }
    //         let productIds = snapshot?.documents.compactMap { $0.data()["productId"] as? Int } ?? []
    //         completion(.success(productIds))
    //     }
    // }
    
    // --- USER PROFILE (Zusatzdaten, falls nicht alles in Firebase Auth/WC ist) ---
    // func saveUserProfileData(userId: String, data: YourUserProfileModel, completion: @escaping (Error?) -> Void) {
    //     do {
    //         try db.collection("users").document(userId).setData(from: data, merge: true) { error in
    //             completion(error)
    //         }
    //     } catch {
    //         completion(error)
    //     }
    // }
    
    // func getUserProfileData(userId: String, completion: @escaping (Result<YourUserProfileModel, Error>) -> Void) {
    //      db.collection("users").document(userId).getDocument { documentSnapshot, error in
    //          // ... Dekodieren ...
    //      }
    // }
}
