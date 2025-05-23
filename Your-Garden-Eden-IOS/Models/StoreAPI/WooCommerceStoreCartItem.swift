//
//  WooCommerceStoreCartItem.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.05.25.
//


// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartItem.swift
import Foundation

struct WooCommerceStoreCartItem: Codable, Hashable, Identifiable { // Identifiable durch `key`
    let key: String
    let id: Int // Produkt- oder Variations-ID
    var quantity: Int // var, da im UI änderbar
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
    let variation: [WooCommerceStoreCartItemVariationAttribute] // Array von Attribut/Wert Paaren
    // let itemData: [AnyCodable]? // Für beliebige Daten, falls benötigt (komplexer)
    let prices: WooCommerceStoreProductPriceInfo? // Das ist das 'prices' Objekt
    let totals: WooCommerceStoreCartItemTotals
    let catalogVisibility: String?

    enum CodingKeys: String, CodingKey {
        case key, id, quantity, name
        case shortDescription = "short_description"
        case description, sku
        case lowStockRemaining = "low_stock_remaining"
        case backordersAllowed = "backorders_allowed"
        case showBackorderBadge = "show_backorder_badge"
        case soldIndividually = "sold_individually"
        case permalink, images, variation, prices, totals // item_data weggelassen für Einfachheit
        case catalogVisibility = "catalog_visibility"
    }
    
    // Um Identifiable durch 'key' zu erfüllen
    var identifiableId: String { key }
}