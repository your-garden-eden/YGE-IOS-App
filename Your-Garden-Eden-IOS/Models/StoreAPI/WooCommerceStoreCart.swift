// Models/WooCommerce/StoreAPI/WooCommerceStoreAPIModels.swift

import Foundation

// MARK: - Main Cart Object
struct WooCommerceStoreCart: Codable, Hashable {
    let coupons: [WooCommerceStoreCartCoupon]
    var shippingRates: [WooCommerceStoreShippingPackage]
    var shippingAddress: WooCommerceStoreAddress
    var billingAddress: WooCommerceStoreAddress
    var items: [WooCommerceStoreCartItem]
    let itemsCount: Int
    let itemsWeight: Double
    let needsPayment: Bool
    let needsShipping: Bool
    let hasCalculatedShipping: Bool
    let totals: WooCommerceStoreCartTotals

    enum CodingKeys: String, CodingKey {
        case coupons, items, totals
        case shippingRates = "shipping_rates"
        case shippingAddress = "shipping_address"
        case billingAddress = "billing_address"
        case itemsCount = "items_count"
        case itemsWeight = "items_weight"
        case needsPayment = "needs_payment"
        case needsShipping = "needs_shipping"
        case hasCalculatedShipping = "has_calculated_shipping"
    }
}

// MARK: - Cart Item and related structs
struct WooCommerceStoreCartItem: Codable, Hashable, Identifiable {
    let key: String
    var id: Int
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
    let totals: WooCommerceStoreCartItemTotals
    let catalogVisibility: String?

    enum CodingKeys: String, CodingKey {
        case key, id, quantity, name, description, sku, permalink, images, variation, prices, totals
        case shortDescription = "short_description"
        case lowStockRemaining = "low_stock_remaining"
        case backordersAllowed = "backorders_allowed"
        case showBackorderBadge = "show_backorder_badge"
        case soldIndividually = "sold_individually"
        case catalogVisibility = "catalog_visibility"
    }
}

struct WooCommerceStoreCartItemImage: Codable, Identifiable, Hashable {
    let id: Int
    let src: String
    let thumbnail: String
    let srcset: String?
    let sizes: String?
    let name: String
    let alt: String
}

struct WooCommerceStoreCartItemVariationAttribute: Codable, Hashable {
    let attribute: String
    let value: String
}

struct WooCommerceStoreProductPriceInfo: Codable, Hashable {
    let price: String
    let regularPrice: String
    let salePrice: String?
    let priceRange: PriceRange?
    let currencyCode: String

    struct PriceRange: Codable, Hashable {
        let minAmount: String; let maxAmount: String
        enum CodingKeys: String, CodingKey { case minAmount = "min_amount"; case maxAmount = "max_amount" }
    }

    enum CodingKeys: String, CodingKey {
        case price
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
        case priceRange = "price_range"
        case currencyCode = "currency_code"
    }
}

struct WooCommerceStoreCartItemTotals: Codable, Hashable {
    let lineSubtotal: String; let lineSubtotalTax: String; let lineTotal: String; let lineTotalTax: String;
    let currencyCode: String; let currencySymbol: String; let currencyMinorUnit: Int;
    let currencyDecimalSeparator: String; let currencyThousandSeparator: String;
    let currencyPrefix: String; let currencySuffix: String

    enum CodingKeys: String, CodingKey {
        case lineSubtotal = "line_subtotal"; case lineSubtotalTax = "line_subtotal_tax"
        case lineTotal = "line_total"; case lineTotalTax = "line_total_tax"
        case currencyCode = "currency_code"; case currencySymbol = "currency_symbol"
        case currencyMinorUnit = "currency_minor_unit"; case currencyDecimalSeparator = "currency_decimal_separator"
        case currencyThousandSeparator = "currency_thousand_separator"; case currencyPrefix = "currency_prefix"
        case currencySuffix = "currency_suffix"
    }
}

// MARK: - Cart-wide Totals and Coupons
struct WooCommerceStoreCartTotals: Codable, Hashable {
    let totalItems: String; let totalItemsTax: String; let totalPrice: String; let totalTax: String;
    let totalShipping: String?; let totalShippingTax: String?; let totalDiscount: String?; let totalDiscountTax: String?;
    let currencyCode: String; let currencySymbol: String;

    enum CodingKeys: String, CodingKey {
        case totalItems = "total_items"; case totalItemsTax = "total_items_tax"
        case totalPrice = "total_price"; case totalTax = "total_tax"
        case totalShipping = "total_shipping"; case totalShippingTax = "total_shipping_tax"
        case totalDiscount = "total_discount"; case totalDiscountTax = "total_discount_tax"
        case currencyCode = "currency_code"; case currencySymbol = "currency_symbol"
    }
}

struct WooCommerceStoreCartCoupon: Codable, Hashable {
    let code: String
    let discountType: String
    let totals: WooCommerceStoreCartTotals

    enum CodingKeys: String, CodingKey { case code, totals; case discountType = "discount_type" }
}

// MARK: - Shipping
struct WooCommerceStoreShippingPackage: Codable, Hashable, Identifiable {
    let packageId: String; let name: String; let destination: WooCommerceStoreAddress
    let items: [ShippingPackageItem]; var shippingRates: [WooCommerceStoreShippingRate]
    var id: String { packageId }
    struct ShippingPackageItem: Codable, Hashable { let key: String; let name: String; let quantity: Int }
    enum CodingKeys: String, CodingKey { case name, destination, items; case packageId = "package_id"; case shippingRates = "shipping_rates" }
}

struct WooCommerceStoreShippingRate: Codable, Hashable, Identifiable {
    let rateId: String; let name: String; let description: String?; let price: String
    let taxes: String; let methodId: String; let instanceId: Int?; var selected: Bool?
    var id: String { rateId }
    enum CodingKeys: String, CodingKey { case name, description, price, taxes, selected; case rateId = "rate_id"; case methodId = "method_id"; case instanceId = "instance_id" }
}

// MARK: - Address
struct WooCommerceStoreAddress: Codable, Hashable {
    var firstName: String?; var lastName: String?; var company: String?; var address1: String?
    var address2: String?; var city: String?; var state: String?; var postcode: String?
    var country: String?; var email: String?; var phone: String?
    enum CodingKeys: String, CodingKey { case company, city, state, postcode, country, email, phone; case firstName = "first_name"; case lastName = "last_name"; case address1 = "address_1"; case address2 = "address_2" }
}
