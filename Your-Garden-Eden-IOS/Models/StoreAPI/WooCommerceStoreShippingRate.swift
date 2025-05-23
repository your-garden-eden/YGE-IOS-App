// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreShippingRate.swift
import Foundation

struct WooCommerceStoreShippingRate: Codable, Hashable, Identifiable {
    let rateId: String
    let name: String
    let description: String?
    let price: String
    let taxes: String
    let methodId: String
    let instanceId: Int?
    var selected: Bool? // var, da änderbar
    // delivery_time und meta_data hier weggelassen, wie in deinem Original

    var id: String { rateId } // Für Identifiable

    enum CodingKeys: String, CodingKey {
        case rateId = "rate_id"
        case name, description, price, taxes, selected
        case methodId = "method_id"
        case instanceId = "instance_id"
    }
}
