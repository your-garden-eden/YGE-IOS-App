//
//  AuthTokenResponse.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.06.25.
//


// DATEI: UserAPIModels.swift
// PFAD: Models/User/UserAPIModels.swift
// VERSION: IDENTITÄT 1.0
// STATUS: NEU

import Foundation

// MARK: - API Response Models

/// Dekodiert die Antwort vom Standard-JWT-Endpunkt (`/token`).
struct AuthTokenResponse: Decodable {
    let token: String
    let user_email: String
    let user_nicename: String      // Dies ist der Benutzername
    let user_display_name: String
}

/// Dekodiert die Antwort vom benutzerdefinierten Registrierungs-Endpunkt (`/register`).
struct RegistrationResponse: Decodable {
    let success: Bool
    let code: String
    let message: String
    let data: RegistrationData
    
    struct RegistrationData: Decodable {
        let status: Int
        let user: UserInfo
    }
    
    struct UserInfo: Decodable {
        let id: Int
        let email: String
        let username: String
    }
}

/// Ein generisches Erfolgsmodell für Endpunkte, die nur eine Bestätigung zurückgeben.
struct SuccessResponse: Decodable {
    let success: Bool
    let message: String
}


// MARK: - API Payload Models

/// Kodiert die Daten für eine neue Benutzerregistrierung.
struct RegistrationPayload: Encodable {
    let username: String
    let email: String
    let password: String
    let first_name: String
    let last_name: String
    let address_1: String
    let postcode: String
    let city: String
    let billing_country: String
    let billing_phone: String
}

/// Kodiert die Daten für eine Passwort-Reset-Anforderung.
struct PasswordResetRequestPayload: Encodable {
    let email: String
}

/// Kodiert die Daten zur Bestätigung eines Passwort-Resets.
struct SetNewPasswordPayload: Encodable {
    let key: String
    let login: String // Der Benutzername, der in der Reset-E-Mail mitgeliefert wird
    let password: String
}

/// Kodiert die Daten für eine Passwort-Änderung durch einen eingeloggten Benutzer.
struct ChangePasswordPayload: Encodable {
    let current_password: String
    let new_password: String
}