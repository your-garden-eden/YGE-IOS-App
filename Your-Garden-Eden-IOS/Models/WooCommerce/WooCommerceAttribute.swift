// Models/WooCommerce/WooCommerceAttribute.swift
import Foundation

struct WooCommerceAttribute: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String? // Optional
    let position: Int
    let visible: Bool
    let variation: Bool
    let options: [String]
}
