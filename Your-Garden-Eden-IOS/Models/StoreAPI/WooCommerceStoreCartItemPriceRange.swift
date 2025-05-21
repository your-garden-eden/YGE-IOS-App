// Models/StoreAPI/WooCommerceStoreCartItemPrices.swift
// Abgeleitet aus `prices` im TS `WooCommerceStoreCartItem`
import Foundation

struct WooCommerceStoreCartItemPriceRange: Codable, Hashable {
    let minAmount: String
    let maxAmount: String

    enum CodingKeys: String, CodingKey {
        case minAmount = "min_amount"
        case maxAmount = "max_amount"
    }
}

struct WooCommerceStoreCartItemPrices: Codable, Hashable {
    let price: String
    let regularPrice: String
    let salePrice: String
    let priceRange: WooCommerceStoreCartItemPriceRange? // War null | { min_amount: string; max_amount: string }
    let currencyCode: String

    enum CodingKeys: String, CodingKey {
        case price
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
        case priceRange = "price_range"
        case currencyCode = "currency_code"
    }
}
