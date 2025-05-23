// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartItem.swift
import Foundation

struct WooCommerceStoreCartItem: Codable, Hashable, Identifiable {
    let key: String
    var id: Int // Produkt- oder Variations-ID (var, falls sich das ändern könnte, sonst let)
    var quantity: Int
    let name: String
    let shortDescription: String?
    let description: String?
    let sku: String?
    let lowStockRemaining: Int?
    let backordersAllowed: Bool?
    let showBackorderBadge: Bool?
    let soldIndividually: Bool?
    let permalink: String?
    let images: [WooCommerceStoreCartItemImage]
    let variation: [WooCommerceStoreCartItemVariationAttribute]
    let prices: WooCommerceStoreProductPriceInfo?
    let totals: WooCommerceStoreCartItemTotals // Hier wird die korrekte Struktur für Item-Summen verwendet
    let catalogVisibility: String?
    // item_data (Array beliebiger Typen) ist komplexer und hier weggelassen.
    // Wenn du es brauchst, müssten wir eine Lösung wie ValueType/AnyCodable dafür finden.

    enum CodingKeys: String, CodingKey {
        case key, id, quantity, name, description, sku, permalink, images, variation, prices, totals
        case shortDescription = "short_description"
        case lowStockRemaining = "low_stock_remaining"
        case backordersAllowed = "backorders_allowed"
        case showBackorderBadge = "show_backorder_badge"
        case soldIndividually = "sold_individually"
        case catalogVisibility = "catalog_visibility"
    }
    
    // Für Identifiable
    // var id: String { key } // Wenn 'key' die primäre ID sein soll.
    // Oder wenn die numerische 'id' gemeint ist (kann bei Variationen problematisch sein, wenn nicht eindeutig über alle Items)
    // Für Listen ist 'key' oft besser, da es einzigartig pro Warenkorbzeile ist.
    // Ich belasse es bei `var id: Int`, aber für `Identifiable` in SwiftUI Listen ist oft der `key` besser.
    // Wenn du `id` (die Produkt/Variations-ID) für Identifiable nehmen willst und mehrere gleiche Produkte
    // als separate Zeilen im Warenkorb erscheinen könnten (was bei WooCommerce Store API nicht der Fall ist,
    // da gleiche Produkte zusammengefasst werden), bräuchtest du eine andere ID.
    // Für die Store API ist der `key` die eindeutige ID des Warenkorbartikels.
}
