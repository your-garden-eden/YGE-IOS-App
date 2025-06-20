// DATEI: AuthManager.swift
// PFAD: Services/App/AuthManager.swift
// VERSION: FINAL - Alle Operationen integriert.

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
    private let logger = LogSentinel.shared

    private init() {
        if getAuthToken() != nil, let data = try? keychain.getData("userProfile"), let savedUser = try? JSONDecoder().decode(UserModel.self, from: data) {
            self.user = savedUser
            self.isLoggedIn = true
            logger.info("Benutzer aus gesicherter Sitzung wiederhergestellt: \(savedUser.email)")
        } else if getAuthToken() != nil {
            logger.warning("Inkonsistente Sitzung gefunden (Token ohne Profil). Automatischer Logout wird durchgeführt.")
            logout()
        }
    }

    func signInWithEmail(email: String, password: String) async throws {
        self.isLoading = true
        defer { self.isLoading = false }
        logger.info("Anmeldeversuch gestartet.")
        
        guard let url = URL(string: authAPI.login) else {
            logger.error("Ungültige API-URL für Login.")
            throw AuthErrorResponse.genericError("Ungültige API-URL.")
        }
        
        let parameters: [String: Any] = ["email": email, "password": password]
        
        do {
            let response = try await performAuthRequest(url: url, parameters: parameters)
            handleSuccess(response)
            logger.info("Anmeldung erfolgreich für Benutzer: \(response.data.user.email)")
        } catch {
            logger.error("Anmeldeversuch fehlgeschlagen: \(error.localizedDescription)")
            throw error
        }
    }

    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String) async throws {
        self.isLoading = true
        defer { self.isLoading = false }
        logger.info("Registrierungsversuch gestartet für E-Mail: \(email).")
        
        guard !authAPI.registrationKey.isEmpty else {
            logger.error("Registrierungsschlüssel ist nicht konfiguriert.")
            throw AuthErrorResponse.genericError("Reg-Schlüssel nicht konfiguriert.")
        }
        guard let url = URL(string: authAPI.register) else {
            logger.error("Ungültige API-URL für Registrierung.")
            throw AuthErrorResponse.genericError("Ungültige API-URL.")
        }
        
        let parameters: [String: Any] = ["email": email, "password": password, "first_name": firstName, "last_name": lastName, "auth_key": authAPI.registrationKey]
        
        do {
            let response = try await performAuthRequest(url: url, parameters: parameters)
            handleSuccess(response)
            logger.info("Registrierung erfolgreich für neuen Benutzer: \(response.data.user.email)")
        } catch {
            logger.error("Registrierungsversuch fehlgeschlagen: \(error.localizedDescription)")
            throw error
        }
    }
    
    func logout() {
        if let userEmail = user?.email {
            logger.info("Logout wird durchgeführt für Benutzer: \(userEmail).")
        } else {
            logger.info("Logout wird durchgeführt (kein Benutzerprofil vorhanden).")
        }
        user = nil
        isLoggedIn = false
        try? keychain.remove("authToken")
        try? keychain.remove("userProfile")
        Task {
            try? KeychainHelper.deleteCartToken()
            logger.info("Warenkorb-Token für ausgeloggten Benutzer gelöscht.")
        }
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
            logger.error("Unbekannter Serverfehler bei Authentifizierung. Status: \(httpResponse.statusCode)")
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
        logger.debug("Auth-Token und Benutzerprofil sicher im Keychain gespeichert.")
    }
}
