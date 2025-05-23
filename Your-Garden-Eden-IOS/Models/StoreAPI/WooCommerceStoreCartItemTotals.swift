// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartTotals.swift
import Foundation

struct WooCommerceStoreCartTotals: Codable, Hashable {
    let totalItems: String
    let totalItemsTax: String
    let totalPrice: String
    let totalTax: String
    let totalShipping: String?
    let totalShippingTax: String?
    let totalDiscount: String?
    let totalDiscountTax: String?
    let currencyCode: String
    let currencySymbol: String
    // currency_minor_unit, etc. falls auf dieser Ebene auch benötigt, sonst aus Item-Totals ableiten

    enum CodingKeys: String, CodingKey {
        case totalItems = "total_items"
        case totalItemsTax = "total_items_tax"
        case totalPrice = "total_price"
        case totalTax = "total_tax"
        case totalShipping = "total_shipping"
        case totalShippingTax = "total_shipping_tax"
        case totalDiscount = "total_discount"
        case totalDiscountTax = "total_discount_tax"
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
    }
}
