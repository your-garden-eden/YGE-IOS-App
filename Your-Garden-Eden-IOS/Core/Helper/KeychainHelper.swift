// DATEI: KeychainHelper.swift
// PFAD: Helper/KeychainHelper.swift
// ZWECK: Kapselt die Interaktion mit dem System-Keychain. Dient als sicherer
//        Speicher für sensible Daten wie den Warenkorb-Token.

import Foundation
import KeychainAccess

public struct KeychainHelper {
    private static let keychain = Keychain(service: "com.yourgardeneden.app.cart")
    
    public static func saveCartToken(_ token: String) throws {
        try keychain.set(token, key: "cartToken")
    }
    
    public static func getCartToken() -> String? {
        return try? keychain.getString("cartToken")
    }
    
    public static func deleteCartToken() throws {
        try keychain.remove("cartToken")
    }
}
