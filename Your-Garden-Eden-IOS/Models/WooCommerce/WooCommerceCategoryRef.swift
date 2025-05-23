// YGE-IOS-App/Core/Models/WooCommerce/WooCommerceCategoryRef.swift
import Foundation

struct WooCommerceCategoryRef: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
}
