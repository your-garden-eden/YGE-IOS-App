//
//  WooCommerceStoreShippingPackage.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.05.25.
//


// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreShippingPackage.swift
import Foundation

struct WooCommerceStoreShippingPackage: Codable, Hashable, Identifiable {
    let packageId: String
    let name: String
    let destination: WooCommerceStoreAddress
    let items: [ShippingPackageItem]
    var shippingRates: [WooCommerceStoreShippingRate] // var, da 'selected' sich ändern kann

    // Um Identifiable zu erfüllen
    var id: String { packageId }

    struct ShippingPackageItem: Codable, Hashable {
        let key: String
        let name: String
        let quantity: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case packageId = "package_id"
        case name, destination, items
        case shippingRates = "shipping_rates"
    }
}