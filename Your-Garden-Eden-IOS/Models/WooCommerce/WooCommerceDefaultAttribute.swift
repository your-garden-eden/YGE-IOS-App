// Models/WooCommerce/WooCommerceDefaultAttribute.swift
import Foundation

struct WooCommerceDefaultAttribute: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let option: String
}
