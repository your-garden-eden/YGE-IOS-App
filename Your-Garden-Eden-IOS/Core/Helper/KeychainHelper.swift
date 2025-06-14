// Path: Your-Garden-Eden-IOS/Core/Helpers/KeychainHelper.swift

import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case itemNotFound, duplicateItem, unexpectedData
    case unhandledError(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .itemNotFound: return "Keychain item not found."
        case .duplicateItem: return "Keychain item already exists."
        case .unexpectedData: return "Unexpected data format from Keychain."
        case .unhandledError(let status): return "Keychain error: OSStatus \(status)"
        }
    }
}

class KeychainHelper {
    private static let serviceName = "com.yourgardeneden.app"
    private static let cartTokenAccount = "userCartTokenV2"

    static func saveCartToken(_ token: String) throws {
        guard let tokenData = token.data(using: .utf8) else { throw KeychainError.unexpectedData }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: cartTokenAccount
        ]

        let attributesToUpdate: [String: Any] = [kSecValueData as String: tokenData]
        let statusUpdate = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        if statusUpdate == errSecSuccess {
            // Updated successfully
        } else if statusUpdate == errSecItemNotFound {
            var newItemQuery = query
            newItemQuery[kSecValueData as String] = tokenData
            newItemQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let statusAdd = SecItemAdd(newItemQuery as CFDictionary, nil)
            if statusAdd != errSecSuccess { throw KeychainError.unhandledError(status: statusAdd) }
        } else {
            throw KeychainError.unhandledError(status: statusUpdate)
        }
    }

    static func getCartToken() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: cartTokenAccount,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let tokenData = item as? Data, let token = String(data: tokenData, encoding: .utf8) else {
                throw KeychainError.unexpectedData
            }
            return token
        case errSecItemNotFound:
            return nil
        default:
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
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
