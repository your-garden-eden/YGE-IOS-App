// Models/StoreAPI/WooCommerceStoreCartItem.swift
import Foundation

// WooCommerceStoreCartItemData war `any[]` in deinem TS für `item_data`.
// Dies ist ein Platzhalter. Du musst ihn anpassen, falls du die Struktur kennst.
// Wenn es immer leer ist oder du es nicht brauchst, kannst du es als `[IgnoredAnyCodable]?` oder weglassen.
struct WooCommerceStoreCartItemData: Codable, Hashable {
    // Beispielhafte Struktur, wenn du weißt, was drin sein könnte:
    // let key: String?
    // let value: String?
    // Passe dies an die tatsächliche Struktur an, falls bekannt.
    // Fürs Erste leer lassen oder als Dummy:
    let dummy: String? // Nur damit es kompiliert, wenn es wirklich any ist und nicht gebraucht wird.
}


struct WooCommerceStoreCartItem: Codable, Identifiable, Hashable {
    let key: String
    let id: Int // Produkt ID
    let quantity: Int
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
    let variation: [WooCommerceStoreCartItemVariation] // Array von { attribute: string; value: string }
    let itemData: [WooCommerceStoreCartItemData]? // War `any[]`, braucht genauere Definition oder muss flexibel gehandhabt werden.
    let prices: WooCommerceStoreCartItemPrices?
    let totals: WooCommerceStoreCartItemTotals
    let catalogVisibility: String?

    enum CodingKeys: String, CodingKey {
        case key, id, quantity, name, description, sku, permalink, images, variation, totals
        case shortDescription = "short_description"
        case lowStockRemaining = "low_stock_remaining"
        case backordersAllowed = "backorders_allowed"
        case showBackorderBadge = "show_backorder_badge"
        case soldIndividually = "sold_individually"
        case itemData = "item_data"
        case prices
        case catalogVisibility = "catalog_visibility"
    }
}
