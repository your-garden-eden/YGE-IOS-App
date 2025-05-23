// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartItemVariationAttribute.swift
import Foundation

struct WooCommerceStoreCartItemVariationAttribute: Codable, Hashable {
    let attribute: String
    let value: String
    // Kein CodingKeys-Enum nötig
}
