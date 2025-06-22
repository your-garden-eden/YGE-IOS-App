// DATEI: AuthManager.swift
// PFAD: Services/App/AuthManager.swift
// VERSION: ADLERAUGE 1.0 (REVIDIERT)
// STATUS: ZURÜCKGESETZT

import Foundation
// import GoogleSignIn <- ENTFERNT

enum AuthState {
    case initializing
    case guest
    case authenticated
}

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published private(set) var authState: AuthState = .initializing
    @Published private(set) var user: UserModel?
    @Published var isLoading: Bool = false
    @Published var authError: String?

    var isLoggedIn: Bool {
        return authState == .authenticated
    }
    
    private var guestAuthToken: String?
    private let logger = LogSentinel.shared
    
    private init() {
        Task {
            if let savedUser = KeychainService.getUserProfile(), let _ = KeychainService.getAuthToken() {
                self.user = savedUser
                self.authState = .authenticated
                logger.info("Benutzer aus gesicherter Sitzung wiederhergestellt: \(savedUser.email)")
            } else {
                await fetchGuestToken()
                self.authState = .guest
            }
        }
    }

    func login(usernameOrEmail: String, password: String) async throws -> UserModel {
        self.isLoading = true
        self.authError = nil
        defer { self.isLoading = false }
        logger.info("Anmeldeversuch gestartet für: \(usernameOrEmail).")
        
        guard let url = URL(string: AppConfig.API.Auth.token) else {
            throw handleError(message: "Ungültige Login-URL.")
        }
        
        let parameters: [String: Any] = ["username": usernameOrEmail, "password": password]
        let body = try JSONSerialization.data(withJSONObject: parameters)
        
        do {
            let response: AuthTokenResponse = try await performRequest(url: url, httpMethod: "POST", body: body)
            return try await handleLoginSuccess(response)
        } catch {
            throw handleError(error: error, message: "Login fehlgeschlagen.")
        }
    }

    // --- BEGINN RÜCKBAU ---
    // Die Funktion signInWithGoogle wurde vollständig entfernt.
    // --- ENDE RÜCKBAU ---

    func register(payload: RegistrationPayload) async throws -> SuccessResponse {
        self.isLoading = true
        self.authError = nil
        defer { self.isLoading = false }
        logger.info("Registrierungsversuch gestartet für E-Mail: \(payload.email).")
        
        guard let url = URL(string: AppConfig.API.Auth.register) else {
            throw handleError(message: "Ungültige Registrierungs-URL.")
        }

        let body = try JSONEncoder().encode(payload)
        
        do {
            let response: SuccessResponse = try await performRequest(url: url, httpMethod: "POST", body: body)
            logger.info("Registrierung erfolgreich für neuen Benutzer: \(payload.email)")
            return response
        } catch {
            throw handleError(error: error, message: "Registrierung fehlgeschlagen.")
        }
    }
    
    func logout() {
        if let userEmail = user?.email {
            logger.info("Logout wird durchgeführt für Benutzer: \(userEmail).")
        } else {
            logger.info("Logout wird durchgeführt (kein Benutzerprofil vorhanden).")
        }
        
        self.authState = .initializing
        self.user = nil
        self.guestAuthToken = nil
        KeychainService.clearAllAuthData()
        KeychainService.deleteCartToken()
        logger.info("Alle Benutzerdaten aus dem Keychain entfernt.")
        
        Task {
            await fetchGuestToken()
            self.authState = .guest
        }
    }

    func requestPasswordReset(email: String) async throws -> SuccessResponse {
        return try await performSimpleRequest(endpoint: AppConfig.API.Auth.requestPasswordReset, payload: ["email": email])
    }

    func requestUsername(email: String) async throws -> SuccessResponse {
        return try await performSimpleRequest(endpoint: AppConfig.API.Auth.requestUsername, payload: ["email": email])
    }
    
    func changePassword(payload: ChangePasswordPayload) async throws -> SuccessResponse {
        guard let url = URL(string: AppConfig.API.Auth.changePassword) else {
            throw handleError(message: "Ungültige URL für Passwortänderung.")
        }
        let body = try JSONEncoder().encode(payload)
        var headers = [String: String]()
        if let token = getAuthToken() { headers["Authorization"] = "Bearer \(token)" }
        return try await performRequest(url: url, httpMethod: "POST", body: body, headers: headers)
    }

    func getAuthToken() -> String? {
        if authState == .authenticated {
            return KeychainService.getAuthToken()
        }
        return guestAuthToken
    }
    
    private func fetchGuestToken() async {
        guard let url = URL(string: AppConfig.API.Auth.guestToken) else {
            logger.error("Ungültige Gast-Token-URL.")
            return
        }
        logger.info("Fordere neuen Gast-Token an...")
        do {
            let response: GuestTokenResponse = try await performRequest(url: url, httpMethod: "GET")
            self.guestAuthToken = response.token
            logger.info("Gast-Token erfolgreich erhalten und im Speicher abgelegt.")
        } catch {
            logger.error("KRITISCHER FEHLER beim Abrufen des Gast-Tokens: \(error.localizedDescription)")
            self.authError = "Die Verbindung zum Shop konnte nicht hergestellt werden. Bitte versuchen Sie es später erneut."
        }
    }
    
    private func handleLoginSuccess(_ response: AuthTokenResponse) async throws -> UserModel {
        guard let payload = decode(jwtToken: response.token),
              let data = payload["data"] as? [String: Any],
              let userData = data["user"] as? [String: Any],
              let idString = userData["id"] as? String,
              let id = Int(idString) else {
            throw handleError(message: "JWT konnte nicht dekodiert werden oder enthält keine Benutzer-ID.")
        }
        
        let newUser = UserModel(id: id, from: response)
        self.user = newUser
        
        KeychainService.saveAuthToken(response.token)
        KeychainService.saveUserProfile(newUser)
        
        self.guestAuthToken = nil
        self.authState = .authenticated
        
        logger.info("Anmeldung erfolgreich für Benutzer: \(newUser.email) (ID: \(newUser.id))")
        logger.debug("Auth-Token und Benutzerprofil sicher im Keychain gespeichert.")
        return newUser
    }
    
    @discardableResult
    private func handleError(error: Error? = nil, message: String) -> Error {
        var finalMessage = message
        if let error = error, let authError = error as? WooCommerceAPIError {
            switch authError {
            case .serverError(_, let msg, let code):
                finalMessage = msg ?? "Serverfehler"
                logger.error("Auth-Fehler (Server): \(finalMessage) | Code: \(code ?? "N/A")")
            default:
                logger.error("Auth-Fehler: \(error.localizedDescription)")
            }
        } else if let error = error {
            finalMessage = error.localizedDescription
            logger.error("Auth-Fehler (Generisch): \(finalMessage)")
        } else {
             logger.error("Auth-Fehler (Unbekannt): \(message)")
        }
        
        self.authError = stripHTML(from: finalMessage)
        return NSError(domain: "com.yourgardeneden.auth", code: 0, userInfo: [NSLocalizedDescriptionKey: self.authError ?? ""])
    }

    private func performRequest<T: Decodable>(url: URL, httpMethod: String, body: Data? = nil, headers: [String: String] = [:]) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.invalidURL }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let (message, code) = WooCommerceAPIManager.shared.parseWooCommerceError(from: data)
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: message, errorCode: code)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func performSimpleRequest(endpoint: String, payload: [String: String]) async throws -> SuccessResponse {
        guard let url = URL(string: endpoint) else { throw handleError(message: "Ungültige URL: \(endpoint)") }
        let body = try JSONSerialization.data(withJSONObject: payload)
        return try await performRequest(url: url, httpMethod: "POST", body: body)
    }
    
    private func decode(jwtToken jwt: String) -> [String: Any]? {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        var base64String = segments[1]
        while base64String.count % 4 != 0 { base64String += "=" }
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
    private func stripHTML(from string: String) -> String {
        return string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
