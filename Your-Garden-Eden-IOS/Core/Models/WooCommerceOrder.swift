// DATEI: WooCommerceOrderModels.swift
// PFAD: Core/Models/WooCommerceOrderModels.swift
// VERSION: 1.1 (ERWEITERT & FINAL)
// STATUS: Vollständig und referenziell intakt.

import Foundation

// ERWEITERUNG: Fehlende Strukturen hinzugefügt.
public struct BillingAddress: Codable {
    public let first_name: String?
    public let last_name: String?
    public let company: String?
    public let address_1: String?
    public let address_2: String?
    public let city: String?
    public let postcode: String?
    public let country: String?
    public let email: String?
    public let phone: String?
}

public struct ShippingAddress: Codable {
    public let first_name: String?
    public let last_name: String?
    public let company: String?
    public let address_1: String?
    public let address_2: String?
    public let city: String?
    public let postcode: String?
    public let country: String?
    public let phone: String?
}

public struct WooCommerceOrder: Codable, Identifiable {
    public let id: Int
    public let number: String
    public let status: String
    public let currency: String
    public let date_created: String?
    public let total: String
    public let billing: BillingAddress
    public let shipping: ShippingAddress
    public let payment_method_title: String
    public let line_items: [WooCommerceOrderLineItem]
}

public struct WooCommerceOrderLineItem: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let quantity: Int
    public let total: String
    public let price: Double
}
