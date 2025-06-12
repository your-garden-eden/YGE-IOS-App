// Core/Managers/AuthManager.swift

import Foundation
import Combine
import KeychainAccess

// MARK: - Data Models for WordPress API Responses

struct AuthResponse: Decodable {
    let success: Bool
    let data: AuthData
}

struct AuthData: Decodable {
    let token: String
    let user: User
}

// HINWEIS: User ist jetzt 'Codable', um sowohl das Lesen (Decode) als auch das Speichern (Encode) zu ermöglichen.
struct User: Codable, Identifiable {
    let id: Int
    let displayName: String
    let email: String
    let firstName: String
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case id, email
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct AuthErrorResponse: Decodable, Error {
    let success: Bool
    let data: ErrorData
    
    // Dies macht die Fehlermeldung direkt für die UI zugänglich.
    var localizedDescription: String {
        // Hier könnten wir `errorCode` nutzen, um die Meldungen zu übersetzen.
        return data.message
    }
}

struct ErrorData: Decodable {
    let message: String
    let errorCode: Int
}


// MARK: - AuthManager

final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    // MARK: - Published Properties for UI
    @Published var user: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var authError: AuthErrorResponse?
    @Published private(set) var errorID = UUID() // Informiert UI über neue Fehler

    private var cancellables = Set<AnyCancellable>()
    private let keychain = Keychain(service: "de.your-garden-eden.app")
    
    // !! WICHTIG !! HIER DEINEN SCHLÜSSEL EINTRAGEN !!
    // Du findest ihn im WP-Admin-Dashboard unter "Simple JWT Login" -> "Register".
    private let registrationAuthKey = "DEIN_REGISTRATION_AUTH_KEY"
    
    private let apiBaseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com/wp-json/simple-jwt-login/v1"

    private init() {
        // Lade Token und Benutzerprofil beim Start, falls vorhanden
        if getAuthToken() != nil {
            self.isLoggedIn = true
            if let userData = try? keychain.getData("userProfile"),
               let savedUser = try? JSONDecoder().decode(User.self, from: userData) {
                self.user = savedUser
            }
            // In einer finalen Version könntest du hier eine Token-Validierung gegen den Server machen.
        }
    }

    // MARK: - Public API
    
    /// Meldet einen Benutzer mit E-Mail und Passwort bei WordPress an.
    func signInWithEmail(email: String, password: String) {
        guard let url = URL(string: "\(apiBaseURL)/auth") else { return setError(message: "Ungültige API-URL.") }
        let parameters: [String: Any] = ["email": email, "password": password]
        performAuthRequest(url: url, parameters: parameters)
    }

    /// Registriert einen neuen Benutzer bei WordPress.
    func signUpWithEmail(email: String, password: String, firstName: String, lastName: String) {
        guard !registrationAuthKey.isEmpty, registrationAuthKey != "DEIN_REGISTRATION_AUTH_KEY" else {
            return setError(message: "Der Registrierungs-Schlüssel ist nicht konfiguriert. Bitte den Entwickler kontaktieren.")
        }
        guard let url = URL(string: "\(apiBaseURL)/users") else { return setError(message: "Ungültige API-URL.") }
        let parameters: [String: Any] = [
            "email": email, "password": password,
            "first_name": firstName, "last_name": lastName,
            "auth_key": registrationAuthKey
        ]
        performAuthRequest(url: url, parameters: parameters)
    }

    /// Meldet den aktuellen Benutzer ab und löscht den lokalen Token.
    func logout() {
        DispatchQueue.main.async {
            self.user = nil
            self.isLoggedIn = false
            try? self.keychain.remove("authToken")
            try? self.keychain.remove("userProfile")
        }
    }
    
    /// Gibt den aktuell gespeicherten JWT aus dem Keychain zurück.
    func getAuthToken() -> String? {
        return try? keychain.getString("authToken")
    }

    // MARK: - Private Helper Methods
    
    private func performAuthRequest(url: URL, parameters: [String: Any]) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.authError = nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap(handleResponse)
            .decode(type: AuthResponse.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleCompletion(completion)
            }, receiveValue: { [weak self] response in
                self?.handleSuccess(response)
            })
            .store(in: &cancellables)
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthErrorResponse(success: false, data: ErrorData(message: "Ungültige Server-Antwort.", errorCode: 0))
        }
        if !(200...299).contains(httpResponse.statusCode) {
            if let authError = try? JSONDecoder().decode(AuthErrorResponse.self, from: data) {
                throw authError
            }
            throw AuthErrorResponse(success: false, data: ErrorData(message: "Unbekannter Serverfehler. Status: \(httpResponse.statusCode)", errorCode: httpResponse.statusCode))
        }
        return data
    }
    
    private func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        self.isLoading = false
        if case .failure(let error) = completion {
            if let authError = error as? AuthErrorResponse {
                self.authError = authError
            } else {
                self.setError(message: error.localizedDescription)
            }
            self.errorID = UUID()
        }
    }
    
    private func handleSuccess(_ response: AuthResponse) {
        self.user = response.data.user
        self.isLoggedIn = true
        try? self.keychain.set(response.data.token, key: "authToken")
        if let userData = try? JSONEncoder().encode(response.data.user) {
           try? self.keychain.set(userData, key: "userProfile")
        }
    }
    
    private func setError(message: String) {
        self.isLoading = false
        self.authError = AuthErrorResponse(success: false, data: ErrorData(message: message, errorCode: -1))
        self.errorID = UUID()
    }
}
