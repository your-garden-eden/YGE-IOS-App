// DATEI: WooCommerceStoreCart.swift
// PFAD: Models/Cart/WooCommerceStoreCart.swift
// VERSION: GUTSCHEIN 1.0
// ÄNDERUNG: Die WooCommerceStoreCoupon-Struktur wurde definiert, um Gutscheindaten zu speichern.

import Foundation

public struct WooCommerceStoreCart: Decodable, Hashable {
    public let items: [Item]?
    public let coupons: [WooCommerceStoreCoupon]?
    public let totals: Totals?
    
    public let fees: [WooCommerceStoreFee]?
    public let errors: [WooCommerceStoreError]?
    public let payment_requirements: [String]?
    public let needs_payment: Bool?
    public let needs_shipping: Bool?
    public let shipping_address: WooCommerceStoreAddress?
    public let billing_address: WooCommerceStoreAddress?
    public let shipping_rates: [WooCommerceShippingPackage]?
    public let payment_methods: [String]?
    public let has_calculated_shipping: Bool?
    public let cross_sells: [WooCommerceProduct]?
    public let items_count: Int?
    public let items_weight: Double?
    public let extensions: [String: String]?
    
    public var safeItems: [Item] { items ?? [] }
    
    public init() {
        self.items = []
        self.totals = nil
        self.coupons = []
        self.fees = []
        self.errors = []
        self.payment_requirements = []
        self.needs_payment = false
        self.needs_shipping = false
        self.shipping_address = nil
        self.billing_address = nil
        self.shipping_rates = []
        self.payment_methods = []
        self.has_calculated_shipping = false
        self.cross_sells = []
        self.items_count = 0
        self.items_weight = 0
        self.extensions = [:]
    }
}

// MARK: - Cart Sub-Models

// === BEGINN MODIFIKATION ===
// NEU: Erweitert um 'code' und Identifiable-Konformität für die UI.
public struct WooCommerceStoreCoupon: Decodable, Hashable, Identifiable {
    public let code: String
    
    // Konformität für Identifiable, damit wir es in SwiftUI ForEach verwenden können.
    public var id: String { code }
}
// === ENDE MODIFIKATION ===

public struct WooCommerceStoreError: Decodable, Hashable {}
public struct WooCommerceStoreFee: Decodable, Hashable {}

public struct WooCommerceStoreAddress: Decodable, Hashable {
    public let first_name: String?
    public let last_name: String?
    public let company: String?
    public let address_1: String?
    public let address_2: String?
    public let city: String?
    public let state: String?
    public let postcode: String?
    public let country: String?
    public let phone: String?
    public let email: String?
}

public struct Item: Decodable, Identifiable, Equatable, Hashable {
    public let key: String
    public let id: Int
    public let quantity: Int
    public let quantity_limits: QuantityLimits?
    public let name: String
    public let totals: ItemTotals
    public let images: [CartImage]
    public let variation: [ItemVariation]?
    public let prices: CartItemPrices?
    
    public struct QuantityLimits: Decodable, Equatable, Hashable {
        public let minimum: Int?
        public let maximum: Int?
        public let multiple_of: Int?
        public let editable: Bool?
    }
    
    public struct ItemTotals: Decodable, Equatable, Hashable {
        public let line_total: String?
        public let line_subtotal: String?
        public let line_subtotal_tax: String?
        public let line_total_tax: String?
    }
    
    public struct CartImage: Decodable, Equatable, Hashable {
        public let id: Int?
        public let src: String?
        public let thumbnail: String?
    }
    
    public struct ItemVariation: Decodable, Equatable, Hashable {
        public let attribute: String?
        public let value: String?
    }
    
    public struct CartItemPrices: Decodable, Equatable, Hashable {
        public let price: String?
        public let regular_price: String?
        public let sale_price: String?
        public let currency_symbol: String?
        public let currency_code: String?
    }
}

public struct Totals: Decodable, Equatable, Hashable {
    public let total_price: String?
    public let currency_symbol: String?
    public let total_items: String?
    public let total_items_tax: String?
    public let currency_code: String?
    public let currency_minor_unit: Int?
    public let total_fees: String?
    public let total_fees_tax: String?
    public let total_discount: String?
    public let total_discount_tax: String?
    public let total_shipping: String?
    public let total_shipping_tax: String?
    public let total_tax: String?
    public let tax_lines: [TaxLine]?

    public var totalPriceFormatted: String {
        PriceFormatter.formatPrice(total_price ?? "0", currencySymbol: currency_symbol ?? "€")
    }

    public struct TaxLine: Decodable, Equatable, Hashable {
        public let name: String?
        public let price: String?
        public let rate: String?
    }
}

public struct WooCommerceShippingPackage: Decodable, Hashable {
    public let package_id: Int?
    public let name: String?
    public let destination: WooCommerceStoreAddress?
    public let items: [ShippingPackageItem]?
    public let shipping_rates: [WooCommerceShippingRate]?
    
    public struct ShippingPackageItem: Decodable, Equatable, Hashable {
        public let key: String?
        public let name: String?
        public let quantity: Int?
    }
    
    public struct WooCommerceShippingRate: Decodable, Equatable, Hashable {
        public let rate_id: String?
        public let name: String?
        public let price: String?
        public let method_id: String?
    }
}
