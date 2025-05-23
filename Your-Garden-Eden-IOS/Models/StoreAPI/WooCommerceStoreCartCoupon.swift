// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartCoupon.swift
import Foundation

struct WooCommerceStoreCartCoupon: Codable, Hashable {
    let code: String
    let discountType: String
    let totals: WooCommerceStoreCartTotals // Verweist auf die korrigierte Struktur für Gesamtsummen

    enum CodingKeys: String, CodingKey {
        case code
        case discountType = "discount_type"
        case totals
    }
}
