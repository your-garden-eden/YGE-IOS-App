import Foundation

// MARK: - WooCommerce Store Cart (Hauptmodell)
// RADIKAL ÜBERARBEITET: Fast alle Eigenschaften sind jetzt optional,
// um einen Absturz bei einem leeren Warenkorb zu verhindern.

struct WooCommerceStoreCart: Codable, Equatable {
    let currency: Currency? // Währungsinformationen sollten relativ stabil sein, aber sicher ist sicher.
    
    // Diese Arrays und Objekte sind die Hauptursache für die Abstürze.
    // Sie werden bei einem leeren Warenkorb oft komplett weggelassen.
    var items: [Item]?
    var coupons: [Coupon]?
    var shippingRates: [ShippingRate]?
    var totals: Totals?

    enum CodingKeys: String, CodingKey {
        case currency
        case items
        case coupons
        case shippingRates = "shipping_rates" // Wichtig: CodingKey beibehalten
        case totals
    }

    // Ein berechneter Wert, um sicherzustellen, dass wir immer ein Array haben,
    // auch wenn die API 'nil' sendet. Erleichtert die UI-Logik.
    var safeItems: [Item] {
        return items ?? []
    }
}

// MARK: - Item (Warenkorb-Artikel)
struct Item: Codable, Equatable, Identifiable {
    let key: String
    let id: Int // Produkt-ID
    let quantity: Int
    let name: String
    let totals: ItemTotals? // Auch die Totals eines Items können fehlen
    let images: [ImageSource]? // Bilder könnten fehlen

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
// ÜBERARBEITET: Alle Eigenschaften sind jetzt optional.
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
}

// MARK: - ShippingRate (Versandtarife)
struct ShippingRate: Codable, Equatable, Identifiable {
    var id: String { rateId } // Für Identifiable
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
