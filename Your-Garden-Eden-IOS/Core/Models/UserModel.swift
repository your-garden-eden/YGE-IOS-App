// DATEI: UserAndAuthModels.swift
// PFAD: Core/Models/UserAndAuthModels.swift
// VERSION: 1.1 (ANGEPASST)
// STATUS: Konvertierungs-Funktionen hinzugefügt.

import Foundation

// MARK: - Core User Model
public struct UserModel: Codable, Identifiable, Equatable {
    public let id: Int
    public let displayName: String
    public let email: String
    public let username: String

    init(id: Int, from response: AuthTokenResponse) {
        self.id = id
        self.email = response.user_email
        self.username = response.user_nicename
        self.displayName = response.user_display_name
    }
}

// MARK: - User Profile & Addresses
public struct UserAddressesResponse: Codable, Equatable {
    var billing: UserAddress
    var shipping: UserAddress
}

public struct UserAddress: Codable, Equatable, Hashable {
    var firstName: String?
    var lastName: String?
    var company: String?
    var address1: String?
    var address2: String?
    var postcode: String?
    var city: String?
    var country: String?
    var phone: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case company
        case address1 = "address_1"
        case address2 = "address_2"
        case postcode, city, country, phone
    }
    
    func asBillingAddress(email: String?) -> BillingAddress {
        return BillingAddress(
            first_name: self.firstName,
            last_name: self.lastName,
            company: self.company,
            address_1: self.address1,
            address_2: self.address2,
            city: self.city,
            postcode: self.postcode,
            country: self.country,
            email: email,
            phone: self.phone
        )
    }
    
    func asShippingAddress() -> ShippingAddress {
        return ShippingAddress(
            first_name: self.firstName,
            last_name: self.lastName,
            company: self.company,
            address_1: self.address1,
            address_2: self.address2,
            city: self.city,
            postcode: self.postcode,
            country: self.country,
            phone: self.phone
        )
    }
}

// MARK: - API Responses (Server -> Client)
struct AuthTokenResponse: Decodable {
    let token: String
    let user_email: String
    let user_nicename: String
    let user_display_name: String
}

struct GuestTokenResponse: Decodable {
    let token: String
}

public struct SuccessResponse: Decodable {
    let success: Bool
    let message: String
}
