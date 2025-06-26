// DATEI: AuthManager.swift
// PFAD: Features/Auth/Services/AuthManager.swift
// VERSION: 2.2 (FINAL REPARIERT)
// STATUS: Login-Fehlerbehandlung endgültig korrigiert.

import Foundation
import Combine

public enum AuthState {
    case initializing
    case guest
    case authenticated
}

@MainActor
public final class AuthManager: ObservableObject {
    public static let shared = AuthManager()
    
    @Published public private(set) var authState: AuthState = .initializing
    @Published public private(set) var user: UserModel?
    @Published public var isLoading: Bool = false
    @Published public var authError: String?

    public var isLoggedIn: Bool {
        return authState == .authenticated
    }
    
    private var guestAuthToken: String?
    private let logger = LogSentinel.shared
    
    private lazy var wishlistState = WishlistState.shared
    private lazy var cartManager = CartAPIManager.shared
    private lazy var localProfileStorage = LocalProfileStorage()
    
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

    public func login(usernameOrEmail: String, password: String) async throws -> UserModel {
        self.isLoading = true; self.authError = nil; defer { self.isLoading = false }
        logger.info("Anmeldeversuch gestartet für: \(usernameOrEmail).")
        
        do {
            let response: AuthTokenResponse = try await performLoginRequest(body: ["username": usernameOrEmail, "password": password])
            return try await handleLoginSuccess(response)
        } catch {
            throw handleError(error: error, message: "Login fehlgeschlagen.")
        }
    }

    public func register(payload: RegistrationPayload) async throws -> SuccessResponse {
        self.isLoading = true; self.authError = nil; defer { self.isLoading = false }
        logger.info("Registrierungsversuch gestartet für E-Mail: \(payload.email).")
        return try await performRequest(endpoint: AppConfig.API.Auth.register, httpMethod: "POST", body: payload)
    }
    
    public func logout() {
        logger.info("Logout wird durchgeführt für Benutzer: \(user?.email ?? "N/A").")
        
        Task {
            await wishlistState.prepareForLogout()
            await cartManager.prepareForLogout()
            localProfileStorage.clearAddresses()
            KeychainService.clearAllAuthData()
            self.authState = .initializing
            self.user = nil
            self.guestAuthToken = nil
            await fetchGuestToken()
            self.authState = .guest
            logger.info("Logout abgeschlossen. System im Gast-Modus.")
        }
    }

    public func requestPasswordReset(email: String) async throws -> SuccessResponse {
        self.isLoading = true; self.authError = nil; defer { self.isLoading = false }
        return try await performRequest(endpoint: AppConfig.API.Auth.requestPasswordReset, httpMethod: "POST", body: ["email": email])
    }

    public func requestUsername(email: String) async throws -> SuccessResponse {
        self.isLoading = true; self.authError = nil; defer { self.isLoading = false }
        return try await performRequest(endpoint: AppConfig.API.Auth.requestUsername, httpMethod: "POST", body: ["email": email])
    }
    
    public func getAuthToken() -> String? {
        return authState == .authenticated ? KeychainService.getAuthToken() : guestAuthToken
    }
    
    private func fetchGuestToken() async {
        logger.info("Fordere neuen Gast-Token an...")
        do {
            let response: GuestTokenResponse = try await performRequest(endpoint: AppConfig.API.Auth.guestToken, httpMethod: "GET")
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
        return newUser
    }
    
    @discardableResult
    private func handleError(error: Error? = nil, message: String) -> Error {
        var finalMessage: String
        if let error = error, let authError = error as? WooCommerceAPIError {
            finalMessage = authError.localizedDescriptionForUser
        } else {
            finalMessage = message
        }
        
        self.authError = finalMessage.strippingHTML()
        logger.error("Auth-Fehler: \(finalMessage) | Ursprungs-Fehler: \(String(describing: error))")
        return NSError(domain: "com.yourgardeneden.auth", code: 0, userInfo: [NSLocalizedDescriptionKey: self.authError ?? ""])
    }
    
    private func performLoginRequest<B: Encodable>(body: B) async throws -> AuthTokenResponse {
        guard let url = URL(string: AppConfig.API.Auth.token) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.invalidURL
        }
        
        let decoder = JSONDecoder()
        
        // VERSUCH 1: Dekodiere als Erfolgs-Antwort (AuthTokenResponse)
        if let successResponse = try? decoder.decode(AuthTokenResponse.self, from: data), !successResponse.token.isEmpty {
            return successResponse
        }
        // VERSUCH 2: Dekodiere als bekannte Fehler-Antwort (WooCommerceErrorResponse)
        else if let errorResponse = try? decoder.decode(WooCommerceErrorResponse.self, from: data) {
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorResponse.message, errorCode: errorResponse.code)
        }
        // FALLBACK: Wenn beides fehlschlägt, ist die Server-Antwort unerwartet.
        else {
            let rawResponse = String(data: data, encoding: .utf8) ?? "Nicht dekodierbare Daten"
            logger.error("Unerwartete Server-Antwort beim Login: \(rawResponse)")
            throw WooCommerceAPIError.decodingError(NSError(domain: "com.yourgardeneden.auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unerwartete Server-Antwort."]))
        }
    }

    private func performRequest<T: Decodable, B: Encodable>(endpoint: String, httpMethod: String, body: B) async throws -> T {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)
        
        return try await executeAndDecode(request: request)
    }
    
    private func performRequest<T: Decodable>(endpoint: String, httpMethod: String) async throws -> T {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        return try await executeAndDecode(request: request)
    }
    
    private func executeAndDecode<T: Decodable>(request: URLRequest) async throws -> T {
        var mutableRequest = request
        if let token = getAuthToken() {
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: mutableRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.invalidURL
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let err = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
        
        if T.self == SuccessResponse.self && data.isEmpty {
            return SuccessResponse(success: true, message: "Operation erfolgreich.") as! T
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch let decodingError {
            if let wooError = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                logger.error("Logischer API Fehler (als Decoding-Fehler getarnt) auf \(request.url?.absoluteString ?? "N/A"): \(wooError.message)")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: wooError.message, errorCode: wooError.code)
            }
            throw decodingError
        }
    }
    
    private func decode(jwtToken jwt: String) -> [String: Any]? {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        var base64String = segments[1]
        while base64String.count % 4 != 0 { base64String += "=" }
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
}
