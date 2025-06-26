
// DATEI: WooCommerceStoreCartModels.swift
// PFAD: Core/Models/WooCommerceStoreCartModels.swift
// VERSION: 2.1 (VOLLSTÄNDIG)
// STATUS: Synchronisiert mit API und UI-Anforderungen.

import Foundation

public struct WooCommerceStoreCart: Decodable, Hashable, Equatable {
    public let items: [Item]?
    public let totals: Totals?
    public let coupons: [Coupon]?
    
    public var safeItems: [Item] { items ?? [] }
}

public struct Item: Decodable, Identifiable, Equatable, Hashable {
    public let key: String
    public let id: Int
    public let quantity: Int
    public let name: String
    public let totals: ItemTotals
    public let images: [WooCommerceImage]
    public let variation: [ItemVariation]?
}

public struct ItemVariation: Decodable, Equatable, Hashable {
    public let attribute: String?
    public let value: String?
}

public struct ItemTotals: Decodable, Equatable, Hashable {
    public let line_subtotal: String?
    public let line_subtotal_tax: String?
    public let line_total: String?
    public let line_total_tax: String?
}

public struct Totals: Decodable, Equatable, Hashable {
    public let total_items: String?
    public let total_items_tax: String?
    public let total_price: String?
    public let total_discount: String?
    public let total_discount_tax: String?
    public let currency_code: String?
    public let currency_symbol: String?
    public let currency_minor_unit: Int?
    
    public var itemCount: Int {
        return Int(total_items ?? "0") ?? 0
    }
}

public struct Coupon: Decodable, Identifiable, Equatable, Hashable {
    public var id: String { code }
    public let code: String
    public let totals: CouponTotals
}

public struct CouponTotals: Decodable, Equatable, Hashable {
    public let total_discount: String
    public let total_discount_tax: String
    public let currency_code: String
}

