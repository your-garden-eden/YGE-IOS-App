// Models/StoreAPI/WooCommerceStoreCartCoupon.swift
import Foundation

struct WooCommerceStoreCartCoupon: Codable, Hashable {
    let code: String
    let discountType: String // War discount_type
    let totals: WooCommerceStoreCartTotals // Hier sind die Totals des Coupons gemeint, Struktur wie Haupt-Totals

    enum CodingKeys: String, CodingKey {
        case code, totals
        case discountType = "discount_type"
    }
}
