// Models/StoreAPI/WooCommerceStoreCart.swift
import Foundation

// Platzhalter für komplexe Typen, die als 'any' oder 'object' im TS waren
struct WooCommerceAnyAddress: Codable, Hashable { /* Definiere Felder, falls bekannt */ }
struct WooCommerceShippingRate: Codable, Hashable { /* Definiere Felder, falls bekannt */ }
struct WooCommerceExtensions: Codable, Hashable { /* Definiere Felder, falls bekannt */ }
struct WooCommerceLinks: Codable, Hashable { /* Definiere Felder, falls bekannt */ }


struct WooCommerceStoreCart: Codable, Hashable {
    let coupons: [WooCommerceStoreCartCoupon]
    let shippingRates: [WooCommerceShippingRate] // war any[]
    let shippingAddress: WooCommerceAnyAddress?  // war any
    let billingAddress: WooCommerceAnyAddress?   // war any
    let items: [WooCommerceStoreCartItem]
    let itemsCount: Int
    let itemsWeight: Double // War number, Double ist passend für Gewicht
    let needsPayment: Bool
    let needsShipping: Bool
    let hasCalculatedShipping: Bool
    let totals: WooCommerceStoreCartTotals
    let links: WooCommerceLinks? // War _links, optional
    let extensions: WooCommerceExtensions? // war object, optional

    enum CodingKeys: String, CodingKey {
        case coupons
        case shippingRates = "shipping_rates"
        case shippingAddress = "shipping_address"
        case billingAddress = "billing_address"
        case items
        case itemsCount = "items_count"
        case itemsWeight = "items_weight"
        case needsPayment = "needs_payment"
        case needsShipping = "needs_shipping"
        case hasCalculatedShipping = "has_calculated_shipping"
        case totals
        case links = "_links"
        case extensions
    }
}
