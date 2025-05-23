// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCart.swift
import Foundation

struct WooCommerceStoreCart: Codable, Hashable {
    // Optional: Der Nonce, der mit dem Cart zurückgegeben werden kann (nicht immer im Haupt-Cart-Objekt, manchmal nur im Header)
    // let cartNonce: String?

    let coupons: [WooCommerceStoreCartCoupon]
    var shippingRates: [WooCommerceStoreShippingPackage] // var, da selektierte Rate sich ändern kann
    var shippingAddress: WooCommerceStoreAddress
    var billingAddress: WooCommerceStoreAddress
    var items: [WooCommerceStoreCartItem] // var, da Items sich ändern können
    let itemsCount: Int
    let itemsWeight: Double // JSON "number" wird oft zu Double in Swift
    let needsPayment: Bool
    let needsShipping: Bool
    let hasCalculatedShipping: Bool
    let totals: WooCommerceStoreCartTotals

    // _links und extensions sind oft komplex und nicht immer für die Client-Logik nötig.
    // Wenn du sie brauchst, müssten sie als eigene Codable Structs definiert werden.
    // let links: StoreCartLinks?
    // let extensions: [String: AnyCodable]? // Benötigt AnyCodable oder manuelle Implementierung

    enum CodingKeys: String, CodingKey {
        // case cartNonce = "cart_nonce" // Falls die API es im Body sendet
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
        // case links = "_links"
        // case extensions // Ohne Mapping, wenn der Key "extensions" ist
    }

    // Manueller Initializer, da Codable-Implementierung für ValueType in WooCommerceMetaData
    // oder andere komplexe Typen den automatischen entfernen könnte,
    // oder wenn du Standardwerte für optionale Arrays setzen willst, die nicht im JSON sind.
    // Für diese Struktur sollte der automatische init(from decoder:) aber funktionieren,
    // solange alle ihre Member-Typen Codable sind.
    // Wenn du ihn nicht brauchst, kannst du ihn weglassen, solange keine manuelle Decodierung nötig ist.

    // Beispiel für einen leeren Warenkorb, nützlich für Initialzustände oder Resets
    static var empty: WooCommerceStoreCart {
        return WooCommerceStoreCart(
            coupons: [],
            shippingRates: [],
            shippingAddress: WooCommerceStoreAddress(), // Annahme: WooCommerceStoreAddress hat einen leeren init()
            billingAddress: WooCommerceStoreAddress(),
            items: [],
            itemsCount: 0,
            itemsWeight: 0.0,
            needsPayment: true, // Typischer Standard
            needsShipping: false, // Hängt von den Items ab, aber als Standard oft false
            hasCalculatedShipping: false,
            totals: WooCommerceStoreCartTotals( // Annahme: WooCommerceStoreCartTotals hat einen passenden init oder ist hier mockbar
                totalItems: "0", totalItemsTax: "0", totalPrice: "0", totalTax: "0",
                totalShipping: "0", totalShippingTax: "0", totalDiscount: "0", totalDiscountTax: "0",
                currencyCode: "EUR", currencySymbol: "€" // Setze hier deine Standardwährung
            )
        )
    }
}

// Optional, falls du die _links-Struktur benötigst und sie standardisiert ist:
// struct StoreCartLinks: Codable, Hashable {
//    let selfLink: [StoreLink]?
//    let collection: [StoreLink]?
//    // ... andere Links
//
//    enum CodingKeys: String, CodingKey {
//        case selfLink = "self"
//        case collection
//    }
// }
//
// struct StoreLink: Codable, Hashable {
//    let href: String
// }
