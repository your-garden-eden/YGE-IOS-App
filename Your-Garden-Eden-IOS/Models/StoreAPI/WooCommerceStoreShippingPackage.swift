// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreShippingPackage.swift
import Foundation

struct WooCommerceStoreShippingPackage: Codable, Hashable, Identifiable {
    let packageId: String
    let name: String
    let destination: WooCommerceStoreAddress
    let items: [ShippingPackageItem]
    var shippingRates: [WooCommerceStoreShippingRate] // var, da 'selected' in Rate sich ändern kann

    var id: String { packageId } // Für Identifiable

    struct ShippingPackageItem: Codable, Hashable { // Innere Struktur
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
