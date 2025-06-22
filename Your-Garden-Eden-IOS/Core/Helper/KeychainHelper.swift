// DATEI: KeychainService.swift
// PFAD: Services/Core/KeychainService.swift (Vorschlag für neuen Speicherort)
// VERSION: IDENTITÄT 1.0
// STATUS: GENERALÜBERHOLT

import Foundation
import KeychainAccess

public enum KeychainService {
    
    // MARK: - Authentication Service
    // Ein dedizierter Keychain-Container für Authentifizierungsdaten.
    private static let authKeychain = Keychain(service: "com.yourgardeneden.app.auth")

    public static func saveAuthToken(_ token: String) {
        try? authKeychain.set(token, key: "authToken")
    }

    public static func getAuthToken() -> String? {
        return try? authKeychain.getString("authToken")
    }

    public static func deleteAuthToken() {
        try? authKeychain.remove("authToken")
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
    
    public static func deleteUserProfile() {
        try? authKeychain.remove("userProfile")
    }
    
    public static func clearAllAuthData() {
        deleteAuthToken()
        deleteUserProfile()
    }

    // MARK: - Cart Service
    // Der bestehende Keychain-Container für den Warenkorb-Token.
    private static let cartKeychain = Keychain(service: "com.yourgardeneden.app.cart")

    public static func saveCartToken(_ token: String) {
        try? cartKeychain.set(token, key: "cartToken")
    }

    public static func getCartToken() -> String? {
        return try? cartKeychain.getString("cartToken")
    }

    public static func deleteCartToken() {
        try? cartKeychain.remove("cartToken")
    }
}
