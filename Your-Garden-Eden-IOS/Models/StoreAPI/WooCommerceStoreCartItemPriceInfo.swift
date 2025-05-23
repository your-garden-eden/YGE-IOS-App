// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreProductPriceInfo.swift
import Foundation

struct WooCommerceStoreProductPriceInfo: Codable, Hashable {
    let price: String
    let regularPrice: String
    let salePrice: String? // salePrice kann null sein, wenn das Produkt nicht im Angebot ist.
    let priceRange: PriceRange?
    let currencyCode: String

    struct PriceRange: Codable, Hashable {
        let minAmount: String
        let maxAmount: String
        
        enum CodingKeys: String, CodingKey {
            case minAmount = "min_amount"
            case maxAmount = "max_amount"
        }
    }

    enum CodingKeys: String, CodingKey {
        case price
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
        case priceRange = "price_range"
        case currencyCode = "currency_code"
    }
}
