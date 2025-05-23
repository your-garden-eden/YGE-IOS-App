// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartItemImage.swift
import Foundation

struct WooCommerceStoreCartItemImage: Codable, Identifiable, Hashable {
    let id: Int
    let src: String
    let thumbnail: String
    let srcset: String?
    let sizes: String?
    let name: String
    let alt: String
    // Kein CodingKeys-Enum nötig, wenn alle Namen übereinstimmen oder von Swift automatisch gemappt werden können.
}
