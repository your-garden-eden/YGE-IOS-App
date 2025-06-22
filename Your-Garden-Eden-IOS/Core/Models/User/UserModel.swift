// DATEI: UserModel.swift
// PFAD: Models/User/UserModel.swift
// VERSION: IDENTITÄT 1.0
// STATUS: MODIFIZIERT

import Foundation

public struct UserModel: Codable, Identifiable {
    public let id: Int
    public let displayName: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let username: String // HINZUGEFÜGT: Für die eindeutige Identifizierung beim Login.

    // Standard-Coding-Keys bleiben für die Kompatibilität mit Keychain-Speicherung.
    enum CodingKeys: String, CodingKey {
        case id, displayName, email, firstName, lastName, username
    }
    
    // NEU: Ein benutzerdefinierter Initializer, um ein UserModel aus der Login-Antwort zu erstellen.
    // Beachtet, dass die WordPress-Benutzer-ID aus der JWT-Antwort extrahiert werden muss.
    init(id: Int, from response: AuthTokenResponse) {
        self.id = id
        self.email = response.user_email
        self.username = response.user_nicename
        self.displayName = response.user_display_name
        
        // Versucht, Vor- und Nachnamen aus dem Anzeigenamen zu extrahieren.
        let nameComponents = response.user_display_name.components(separatedBy: " ")
        self.firstName = nameComponents.first ?? ""
        self.lastName = nameComponents.count > 1 ? nameComponents.last ?? "" : ""
    }
}
