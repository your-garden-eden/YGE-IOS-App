// YGE-IOS-App/Core/Models/WooCommerce/WooCommerceImage.swift (oder wo du Models ablegst)
import Foundation

struct WooCommerceImage: Codable, Identifiable, Hashable { // Hashable für diffable data sources
    let id: Int
    let dateCreated: String? // Mache optional, wenn nicht immer vorhanden
    let dateCreatedGmt: String?
    let dateModified: String?
    let dateModifiedGmt: String?
    let src: String
    let name: String
    let alt: String
    let position: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case dateCreated = "date_created"
        case dateCreatedGmt = "date_created_gmt"
        case dateModified = "date_modified"
        case dateModifiedGmt = "date_modified_gmt"
        case src, name, alt, position
    }
}
