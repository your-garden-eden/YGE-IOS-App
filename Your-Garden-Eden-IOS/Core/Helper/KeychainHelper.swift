import Foundation
import KeychainAccess

struct KeychainHelper {
    private static let keychain = Keychain(service: "com.yourgardeneden.app.cart")
    
    static func saveCartToken(_ token: String) throws {
        try keychain.set(token, key: "cartToken")
    }
    
    static func getCartToken() -> String? {
        return try? keychain.getString("cartToken")
    }
    
    static func deleteCartToken() throws {
        try keychain.remove("cartToken")
    }
}
