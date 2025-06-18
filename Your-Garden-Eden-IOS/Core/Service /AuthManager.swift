// DATEI: AuthManager.swift
// PFAD: Services/App/AuthManager.swift
// VERSION: 2.1 (FEHLER BEHOBEN)

import Foundation
import KeychainAccess

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published private(set) var user: UserModel?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false

    private let keychain = Keychain(service: "com.yourgardeneden.app.auth")
    private let authAPI = AppConfig.Auth.self

    private init() {
        if getAuthToken() != nil, let data = try? keychain.getData("userProfile"), let savedUser = try? JSONDecoder().decode(UserModel.self, from: data) {
            self.user = savedUser
            self.isLoggedIn = true
        } else if getAuthToken() != nil {
            logout()
        }
    }

    func signInWithEmail(email: String, password: String) async throws {
        self.isLoading = true
        defer { self.isLoading = false }
        
        // KORREKTUR: `loginEndpoint` wurde zu `login` in AppConfig.
        guard let url = URL(string: authAPI.login) else { throw AuthErrorResponse.genericError("Ungültige API-URL.") }
        let parameters: [String: Any] = ["email": email, "password": password]
        let response = try await performAuthRequest(url: url, parameters: parameters)
        handleSuccess(response)
    }

    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String) async throws {
        self.isLoading = true
        defer { self.isLoading = false }
        
        // KORREKTUR: `registrationAuthKey` wurde zu `registrationKey` in AppConfig.
        guard !authAPI.registrationKey.isEmpty else { throw AuthErrorResponse.genericError("Reg-Schlüssel nicht konfiguriert.") }
        // KORREKTUR: `registerEndpoint` wurde zu `register` in AppConfig.
        guard let url = URL(string: authAPI.register) else { throw AuthErrorResponse.genericError("Ungültige API-URL.") }
        let parameters: [String: Any] = ["email": email, "password": password, "first_name": firstName, "last_name": lastName, "auth_key": authAPI.registrationKey]
        let response = try await performAuthRequest(url: url, parameters: parameters)
        handleSuccess(response)
    }
    
    func logout() {
        user = nil
        isLoggedIn = false
        try? keychain.remove("authToken")
        try? keychain.remove("userProfile")
        Task { try? KeychainHelper.deleteCartToken() }
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
        
        guard let httpResponse = response as? HTTPURLResponse else { throw AuthErrorResponse.genericError("Ungültige Server-Antwort.") }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let authError = try? JSONDecoder().decode(AuthErrorResponse.self, from: data) { throw authError }
            throw AuthErrorResponse.genericError("Unbekannter Serverfehler. Status: \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    private func handleSuccess(_ response: AuthResponse) {
        user = response.data.user
        isLoggedIn = true
        try? keychain.set(response.data.token, key: "authToken")
        if let userData = try? JSONEncoder().encode(response.data.user) {
            try? keychain.set(userData, key: "userProfile")
        }
    }
}
