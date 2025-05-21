// Models/StoreAPI/WooCommerceStoreCartItemImage.swift
import Foundation

struct WooCommerceStoreCartItemImage: Codable, Identifiable, Hashable {
    let id: Int
    let src: String
    let thumbnail: String
    let srcset: String? // Im TS nicht explizit optional, aber bei API-Antworten oft sicherer
    let sizes: String?  // dito
    let name: String
    let alt: String
}
