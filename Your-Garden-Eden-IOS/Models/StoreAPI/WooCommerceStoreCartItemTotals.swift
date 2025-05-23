// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartItemTotals.swift
import Foundation

struct WooCommerceStoreCartItemTotals: Codable, Hashable {
    let lineSubtotal: String
    let lineSubtotalTax: String
    let lineTotal: String
    let lineTotalTax: String
    let currencyCode: String
    let currencySymbol: String
    let currencyMinorUnit: Int
    let currencyDecimalSeparator: String
    let currencyThousandSeparator: String
    let currencyPrefix: String
    let currencySuffix: String

    enum CodingKeys: String, CodingKey {
        case lineSubtotal = "line_subtotal"
        case lineSubtotalTax = "line_subtotal_tax"
        case lineTotal = "line_total"
        case lineTotalTax = "line_total_tax"
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case currencyMinorUnit = "currency_minor_unit"
        case currencyDecimalSeparator = "currency_decimal_separator"
        case currencyThousandSeparator = "currency_thousand_separator"
        case currencyPrefix = "currency_prefix"
        case currencySuffix = "currency_suffix"
    }
}
