//
//  AuthResponse.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: AuthModels.swift
// PFAD: Models/AuthModels.swift
// ZWECK: Definiert die Datenstrukturen für die Antworten der Authentifizierungs-API.

import Foundation

struct AuthResponse: Decodable {
    let success: Bool
    let data: AuthData
}

struct AuthData: Decodable {
    let token: String
    let user: UserModel
}

/// Ein dekodierbares Fehlerobjekt, das von der JWT-Auth-API zurückgegeben wird.
struct AuthErrorResponse: Decodable, Error {
    let success: Bool
    let data: ErrorData
    
    /// Stellt eine benutzerfreundliche Fehlermeldung bereit.
    var localizedDescription: String {
        return data.message.strippingHTML()
    }
    
    /// Erzeugt einen generischen Fehler, falls die API-Antwort nicht dekodiert werden kann.
    static func genericError(_ message: String) -> AuthErrorResponse {
        return AuthErrorResponse(success: false, data: ErrorData(message: message, errorCode: -1))
    }
}

struct ErrorData: Decodable {
    let message: String
    let errorCode: Int
}
struct GuestTokenResponse: Decodable {
    let token: String
}
