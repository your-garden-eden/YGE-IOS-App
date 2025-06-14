// Path: Your-Garden-Eden-IOS/Core/Service/AuthManager.swift
// FINAL KORRIGIERT

import Foundation
import KeychainAccess

// MARK: - Data Models for Auth
struct AuthResponse: Decodable {
    let success: Bool
    let data: AuthData
}

struct AuthData: Decodable {
    let token: String
    let user: UserModel
}

struct AuthErrorResponse: Decodable, Error {
    let success: Bool
    let data: ErrorData
    
    var localizedDescription: String {
        return data.message.strippingHTML()
    }
    
    // KORREKTUR: Die Funktion wird direkt hier als statische Methode deklariert.
    // So ist sie untrennbar mit der Struktur verbunden.
    static func genericError(_ message: String) -> AuthErrorResponse {
        return AuthErrorResponse(success: false, data: ErrorData(message: message, errorCode: -1))
    }
}

struct ErrorData: Decodable {
    let message: String
    let errorCode: Int
}

// MARK: - AuthManager
@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published private(set) var user: UserModel?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false

    private let keychain = Keychain(service: "com.yourgardeneden.app")
    private let apiBaseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com/wp-json/simple-jwt-login/v1"
    private let registrationAuthKey = "YGE-app-register-user"

    private init() {
        if getAuthToken() != nil {
            if let userData = try? keychain.getData("userProfile"),
               let savedUser = try? JSONDecoder().decode(UserModel.self, from: userData) {
                self.user = savedUser
                self.isLoggedIn = true
                print("✅ AuthManager: User loaded from Keychain.")
            } else {
                logout()
                print("⚠️ AuthManager: Found auth token but no user profile. Logging out.")
            }
        }
    }

    func signInWithEmail(email: String, password: String) async throws {
        self.isLoading = true
        defer { self.isLoading = false }
        
        guard let url = URL(string: "\(apiBaseURL)/auth") else { throw AuthErrorResponse.genericError("Ungültige API-URL.") }
        let parameters: [String: Any] = ["email": email, "password": password]
        
        let response = try await performAuthRequest(url: url, parameters: parameters)
        handleSuccess(response)
    }

    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String) async throws {
        self.isLoading = true
        defer { self.isLoading = false }
        
        guard !registrationAuthKey.isEmpty else {
            throw AuthErrorResponse.genericError("Der Registrierungs-Schlüssel ist serverseitig nicht konfiguriert.")
        }
        guard let url = URL(string: "\(apiBaseURL)/users") else { throw AuthErrorResponse.genericError("Ungültige API-URL.") }
        let parameters: [String: Any] = [
            "email": email, "password": password,
            "first_name": firstName, "last_name": lastName,
            "auth_key": registrationAuthKey
        ]
        
        let response = try await performAuthRequest(url: url, parameters: parameters)
        handleSuccess(response)
    }

    func logout() {
        self.user = nil
        self.isLoggedIn = false
        try? self.keychain.remove("authToken")
        try? self.keychain.remove("userProfile")
        Task { try? KeychainHelper.deleteCartToken() }
        print("🔐 AuthManager: User logged out and session cleared.")
    }
    
    func getAuthToken() -> String? {
        return try? keychain.getString("authToken")
    }

    private func performAuthRequest(url: URL, parameters: [String: Any]) async throws -> AuthResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthErrorResponse.genericError("Ungültige Server-Antwort.")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let authError = try? JSONDecoder().decode(AuthErrorResponse.self, from: data) {
                print("🔴 AuthManager Error: \(authError.localizedDescription)")
                throw authError
            }
            throw AuthErrorResponse.genericError("Unbekannter Serverfehler. Status: \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    private func handleSuccess(_ response: AuthResponse) {
        self.user = response.data.user
        self.isLoggedIn = true
        try? self.keychain.set(response.data.token, key: "authToken")
        if let userData = try? JSONEncoder().encode(response.data.user) {
           try? self.keychain.set(userData, key: "userProfile")
        }
        print("✅ AuthManager: Auth success for user \(response.data.user.displayName).")
    }
}
