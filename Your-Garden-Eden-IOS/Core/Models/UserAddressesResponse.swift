// DATEI: ProfileModels.swift
// PFAD: Models/User/ProfileModels.swift
// VERSION: STAMMDATEN 1.0
// STATUS: NEU

import Foundation

/// Dient als Container für die Antwort des `/user/addresses`-Endpunkts.
/// Enthält die Rechnungs- und Lieferadresse des Benutzers.
struct UserAddressesResponse: Codable, Equatable {
    var billing: UserAddress
    var shipping: UserAddress
}

/// Repräsentiert eine einzelne Adresse (Rechnung oder Versand).
/// Die Struktur ist `Equatable`, um später einfach feststellen zu können, ob sich Daten geändert haben.
/// Die Eigenschaften sind als `var` deklariert, um eine Bindung und Bearbeitung in der UI zu ermöglichen.
struct UserAddress: Codable, Equatable {
    var firstName: String
    var lastName: String
    var company: String
    var address1: String
    var address2: String
    var postcode: String
    var city: String
    var country: String
    var state: String
    var email: String? // Nur bei Rechnungsadresse garantiert vorhanden
    var phone: String? // Nur bei Rechnungsadresse garantiert vorhanden

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case company
        case address1 = "address_1"
        case address2 = "address_2"
        case postcode
        case city
        case country
        case state
        case email
        case phone
    }
    
    // Stellt einen leeren Initialisierer bereit, um einen sauberen Ausgangszustand im ViewModel zu ermöglichen.
    init() {
        self.firstName = ""
        self.lastName = ""
        self.company = ""
        self.address1 = ""
        self.address2 = ""
        self.postcode = ""
        self.city = ""
        self.country = ""
        self.state = ""
        self.email = ""
        self.phone = ""
    }
}
