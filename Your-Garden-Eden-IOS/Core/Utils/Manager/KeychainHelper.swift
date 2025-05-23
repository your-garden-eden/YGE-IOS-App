// Utils/KeychainHelper.swift
import Foundation
import Security // Wichtig: Security Framework importieren

// Enum für mögliche Keychain-Fehler
enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case duplicateItem
    case unexpectedData
    case unhandledError(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Keychain item not found."
        case .duplicateItem:
            return "Keychain item already exists."
        case .unexpectedData:
            return "Unexpected data format retrieved from Keychain."
        case .unhandledError(let status):
            return "An unexpected Keychain error occurred: OSStatus \(status)"
        }
    }
}

class KeychainHelper {

    // Eindeutiger Service-Name für deine App, um Konflikte zu vermeiden
    // Es ist gut, hier den Bundle Identifier deiner App zu verwenden.
    private static let serviceName = "com.yourgardeneden.app" // Passe dies ggf. an deinen Bundle Identifier an
    // Key für das Cart-Token im Keychain
    private static let cartTokenAccount = "userCartTokenV1" // "V1" hinzugefügt, falls du alte UserDefaults-Versionen hattest, um Konflikte zu vermeiden

    // MARK: - Cart Token Operations

    static func saveCartToken(_ token: String) throws {
        guard let tokenData = token.data(using: .utf8) else {
            print("KeychainHelper: Error converting token to data.")
            throw KeychainError.unexpectedData
        }

        // Query zum Suchen eines vorhandenen Items
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: cartTokenAccount
        ]

        // Attribute für das Update (wenn das Item bereits existiert)
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: tokenData
        ]

        // Versuche, das Item zu aktualisieren
        let statusUpdate = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        switch statusUpdate {
        case errSecSuccess:
            print("KeychainHelper: Cart token updated successfully in Keychain.")
        case errSecItemNotFound:
            // Item nicht gefunden, also füge es hinzu
            var newItemQuery = query
            newItemQuery[kSecValueData as String] = tokenData
            // Setze die Zugriffssteuerung (Accessibility)
            // kSecAttrAccessibleWhenUnlocked: Daten sind zugänglich, nachdem das Gerät einmal entsperrt wurde. Bleibt zugänglich, bis das Gerät neu gestartet wird.
            // kSecAttrAccessibleAfterFirstUnlock: Ähnlich, aber bleibt auch nach Neustart zugänglich, bis zur nächsten Entsperrung.
            // kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly: Daten sind nur auf diesem Gerät zugänglich, wenn eine Passcode-Sperre aktiv ist.
            newItemQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly // Gute Standardwahl

            let statusAdd = SecItemAdd(newItemQuery as CFDictionary, nil)
            if statusAdd == errSecSuccess {
                print("KeychainHelper: Cart token saved successfully to Keychain.")
            } else {
                print("KeychainHelper: Error saving cart token to Keychain. Status: \(statusAdd)")
                throw KeychainError.unhandledError(status: statusAdd)
            }
        default:
            print("KeychainHelper: Error updating cart token in Keychain. Status: \(statusUpdate)")
            throw KeychainError.unhandledError(status: statusUpdate)
        }
    }

    static func getCartToken() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: cartTokenAccount,
            kSecReturnData as String: kCFBooleanTrue!, // Wir wollen die Daten zurückbekommen
            kSecMatchLimit as String: kSecMatchLimitOne // Wir erwarten nur ein Ergebnis
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let tokenData = item as? Data,
                  let token = String(data: tokenData, encoding: .utf8) else {
                print("KeychainHelper: Unexpected data format or failed to convert token data from Keychain.")
                throw KeychainError.unexpectedData
            }
            print("KeychainHelper: Cart token retrieved successfully from Keychain.")
            return token
        case errSecItemNotFound:
            print("KeychainHelper: Cart token not found in Keychain.")
            return nil // Kein Fehler, einfach kein Token vorhanden
        default:
            print("KeychainHelper: Error retrieving cart token from Keychain. Status: \(status)")
            throw KeychainError.unhandledError(status: status)
        }
    }

    static func deleteCartToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: cartTokenAccount
        ]

        let status = SecItemDelete(query as CFDictionary)

        switch status {
        case errSecSuccess, errSecItemNotFound: // Auch als Erfolg werten, wenn es nicht da war
            print("KeychainHelper: Cart token deleted from Keychain (or was not found).")
        default:
            print("KeychainHelper: Error deleting cart token from Keychain. Status: \(status)")
            throw KeychainError.unhandledError(status: status)
        }
    }

    // Die Nonce-Methoden sind entfernt, da die Nonce nicht im Keychain gespeichert wird.
}
