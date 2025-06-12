// Dateiname: z.B. WooCommerceStoreCart.swift
import Foundation

// MARK: - WooCommerce Store Cart (Hauptmodell)
struct WooCommerceStoreCart: Codable, Equatable {
    let currency: Currency?
    var items: [Item]?
    var coupons: [Coupon]?
    var shippingRates: [ShippingRate]?
    var totals: Totals?

    enum CodingKeys: String, CodingKey {
        case currency
        case items
        case coupons
        case shippingRates = "shipping_rates"
        case totals
    }

    var safeItems: [Item] {
        return items ?? []
    }
}

// MARK: - Item (Warenkorb-Artikel)
struct Item: Codable, Equatable, Identifiable {
    let key: String
    let id: Int
    let quantity: Int
    let name: String
    let totals: ItemTotals?
    let images: [ImageSource]?

    struct ItemTotals: Codable, Equatable {
        let lineTotal: String?
        let lineSubtotal: String?

        enum CodingKeys: String, CodingKey {
            case lineTotal = "line_total"
            case lineSubtotal = "line_subtotal"
        }
    }

    struct ImageSource: Codable, Equatable {
        let id: Int
        let src: String
        let thumbnail: String
        let alt: String
    }
}

// MARK: - Totals (Gesamtsummen)
struct Totals: Codable, Equatable {
    let totalItems: String?
    let totalPrice: String?
    let totalShipping: String?
    let currencyCode: String?
    let currencySymbol: String?

    enum CodingKeys: String, CodingKey {
        case totalItems = "total_items"
        case totalPrice = "total_price"
        case totalShipping = "total_shipping"
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
    }

    // --- START: BERECHNETE EIGENSCHAFTEN ---
    var totalItemsPriceFormatted: String {
        return PriceFormatter.formatPrice(totalItems, currencySymbol: currencySymbol ?? "€")
    }

    var totalShippingFormatted: String {
        if totalShipping == "0" {
            return "Kostenlos"
        }
        return PriceFormatter.formatPrice(totalShipping, currencySymbol: currencySymbol ?? "€")
    }

    var totalPriceFormatted: String {
        return PriceFormatter.formatPrice(totalPrice, currencySymbol: currencySymbol ?? "€")
    }
    // --- ENDE: BERECHNETE EIGENSCHAFTEN ---
}

// MARK: - ShippingRate (Versandtarife)
struct ShippingRate: Codable, Equatable, Identifiable {
    var id: String { rateId }
    let rateId: String
    let name: String
    let price: String
    let methodId: String

    enum CodingKeys: String, CodingKey {
        case rateId = "rate_id"
        case name
        case price
        case methodId = "method_id"
    }
}

// MARK: - Coupon
struct Coupon: Codable, Equatable {
    let code: String
    let totals: CouponTotals?

    struct CouponTotals: Codable, Equatable {
        let totalDiscount: String?

        enum CodingKeys: String, CodingKey {
            case totalDiscount = "total_discount"
        }
    }
}

// MARK: - Currency (Währung)
struct Currency: Codable, Equatable {
    let currencyCode: String
    let currencySymbol: String

    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
    }
}
