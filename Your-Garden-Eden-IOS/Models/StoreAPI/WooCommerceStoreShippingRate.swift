//
//  WooCommerceStoreShippingRate.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.05.25.
//


// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreShippingRate.swift
import Foundation

struct WooCommerceStoreShippingRate: Codable, Hashable, Identifiable {
    let rateId: String
    let name: String
    let description: String?
    // let deliveryTime: DeliveryTime? // Nested struct falls benötigt
    let price: String
    let taxes: String
    let methodId: String
    let instanceId: Int?
    // let metaData: [WooCommerceMetaData]? // Standard WooCommerceMetaData, falls vorhanden
    var selected: Bool? // var, da im Checkout änderbar

    // Um Identifiable zu erfüllen
    var id: String { rateId }

    enum CodingKeys: String, CodingKey {
        case rateId = "rate_id"
        case name, description, price, taxes, selected // delivery_time, meta_data weggelassen
        case methodId = "method_id"
        case instanceId = "instance_id"
    }
}