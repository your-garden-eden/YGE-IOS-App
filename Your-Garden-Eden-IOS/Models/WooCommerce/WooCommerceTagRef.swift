// Models/WooCommerce/WooCommerceTagRef.swift
import Foundation

struct WooCommerceTagRef: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
}
