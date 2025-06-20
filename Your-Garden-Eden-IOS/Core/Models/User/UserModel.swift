//
//  UserModel.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: UserModels.swift
// PFAD: Models/UserModels.swift
// ZWECK: Definiert Datenmodelle im Zusammenhang mit dem Benutzer und der Authentifizierung.

import Foundation

public struct UserModel: Codable, Identifiable {
    public let id: Int
    public let displayName: String
    public let email: String
    public let firstName: String
    public let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
    }
}