//
//  WooCommerceStoreAddress.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.05.25.
//


// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreAddress.swift
import Foundation

struct WooCommerceStoreAddress: Codable, Hashable {
    var firstName: String? // var, da im Checkout änderbar
    var lastName: String?
    var company: String?
    var address1: String?
    var address2: String?
    var city: String?
    var state: String?
    var postcode: String?
    var country: String?
    var email: String?
    var phone: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case company
        case address1 = "address_1"
        case address2 = "address_2"
        case city, state, postcode, country, email, phone
    }
    
    // Initializer für leere Adresse
    init(firstName: String? = nil, lastName: String? = nil, company: String? = nil,
         address1: String? = nil, address2: String? = nil, city: String? = nil,
         state: String? = nil, postcode: String? = nil, country: String? = nil,
         email: String? = nil, phone: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.state = state
        self.postcode = postcode
        self.country = country
        self.email = email
        self.phone = phone
    }
}