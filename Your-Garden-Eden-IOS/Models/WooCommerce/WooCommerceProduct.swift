// YGE-IOS-App/Core/Models/WooCommerce/WooCommerceProduct.swift
import Foundation

struct WooCommerceProduct: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
    let permalink: String
    let dateCreated: String
    let type: ProductType // Eigener Enum für Typ-Sicherheit
    let status: String // Oder Enum
    let featured: Bool
    let description: String
    let shortDescription: String
    let sku: String
    let price: String
    let regularPrice: String
    let salePrice: String? // Oft null
    let priceHtml: String?
    let onSale: Bool
    let purchasable: Bool
    let stockStatus: StockStatus // Eigener Enum
    let averageRating: String
    let ratingCount: Int
    let images: [WooCommerceImage]
    let categories: [WooCommerceCategoryRef]
    let attributes: [WooCommerceAttribute] // Braucht eigenes Struct WooCommerceAttribute
    let variations: [Int] // IDs der Variationen
    let metaData: [WooCommerceMetaData] // Braucht eigenes Struct WooCommerceMetaData

    enum CodingKeys: String, CodingKey {
        case id, name, slug, permalink, type, status, featured, description, sku, price
        case dateCreated = "date_created"
        case shortDescription = "short_description"
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
        case priceHtml = "price_html"
        case onSale = "on_sale"
        case purchasable
        case stockStatus = "stock_status"
        case averageRating = "average_rating"
        case ratingCount = "rating_count"
        case images, categories, attributes, variations
        case metaData = "meta_data"
    }
}

enum ProductType: String, Codable, Hashable {
    case simple, variable, grouped, external
}

enum StockStatus: String, Codable, Hashable {
    case instock, outofstock, onbackorder
}

// ... (Weitere structs wie WooCommerceAttribute, WooCommerceMetaData hier definieren)
