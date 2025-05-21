// Models/StoreAPI/WooCommerceStoreCartItemVariation.swift
// Dieses Modell wurde aus `variation: { attribute: string; value: string }[]` im TS abgeleitet
import Foundation

struct WooCommerceStoreCartItemVariation: Codable, Hashable {
    let attribute: String
    let value: String
}
