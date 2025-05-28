// YGE-IOS-App/Core/Models/WooCommerce/CoreAPI/WooCommerceCategory.swift
import Foundation

struct WooCommerceCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
    let parent: Int
    let description: String
    let display: String
    let image: WooCommerceImage? // WooCommerceImage muss Codable und Hashable sein
    let menuOrder: Int         // Wird von "menu_order" durch .convertFromSnakeCase gemappt
    let count: Int

    // KEIN CodingKeys Enum hier, wenn .convertFromSnakeCase alle Keys abdeckt
    // und die Swift Property Namen die camelCase Versionen der snake_case JSON Keys sind.

    // Manuelle Hashable und Equatable Implementierung (wenn benötigt, ist aber okay so)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: WooCommerceCategory, rhs: WooCommerceCategory) -> Bool {
        return lhs.id == rhs.id
    }
}
