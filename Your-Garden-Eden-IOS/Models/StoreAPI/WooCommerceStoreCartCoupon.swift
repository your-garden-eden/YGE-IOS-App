// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartCoupon.swift
import Foundation

struct WooCommerceStoreCartCoupon: Codable, Hashable {
    let code: String
    let discountType: String // z.B. "percent", "fixed_cart"
    let totals: WooCommerceStoreCartTotals // Zeigt, wie sich der Coupon auf die Summen auswirkt

    enum CodingKeys: String, CodingKey {
        case code
        case discountType = "discount_type"
        case totals
    }
}
