// DATEI: KeychainService.swift
// PFAD: Core/Services/KeychainService.swift
// VERSION: 1.0 (FINAL)
// STATUS: BEST-PRACTICE ARCHITEKTUR.

import Foundation
import KeychainAccess

public enum KeychainService {
    
    private static let serviceIdentifier = "com.yourgardeneden.app"
    
    // Ein dedizierter Keychain-Container für Authentifizierungsdaten.
    private static let authKeychain = Keychain(service: "\(serviceIdentifier).auth")

    public static func saveAuthToken(_ token: String) {
        try? authKeychain.set(token, key: "authToken")
    }

    public static func getAuthToken() -> String? {
        return try? authKeychain.getString("authToken")
    }
    
    public static func saveUserProfile(_ user: UserModel) {
        if let data = try? JSONEncoder().encode(user) {
            try? authKeychain.set(data, key: "userProfile")
        }
    }
    
    public static func getUserProfile() -> UserModel? {
        guard let data = try? authKeychain.getData("userProfile") else { return nil }
        return try? JSONDecoder().decode(UserModel.self, from: data)
    }
    
    public static func clearAllAuthData() {
        try? authKeychain.removeAll()
    }

    // Ein dedizierter Keychain-Container für den Warenkorb-Token.
    private static let cartKeychain = Keychain(service: "\(serviceIdentifier).cart")

    public static func saveCartToken(_ token: String) {
        try? cartKeychain.set(token, key: "cartToken")
    }

    public static func getCartToken() -> String? {
        return try? cartKeychain.getString("cartToken")
    }
}
