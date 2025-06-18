//
//  StockStatus.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: ProductModels.swift
// PFAD: Models/ProductModels.swift
// ZWECK: Definiert die zentralen Datenmodelle für Produkte, Kategorien und deren
//        Attribute, wie sie von der WooCommerce API geliefert werden.

import Foundation

// MARK: - Enums & Shared Sub-Models

public enum StockStatus: String, Codable, Hashable {
    case instock
    case outofstock
    case onbackorder
}

public struct WooCommerceCategoryRef: Codable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
}

public struct WooCommerceImage: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let src: String
    public let name: String?
    public let alt: String?
}

public struct WooCommerceAttribute: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let variation: Bool
    public let options: [String]
}

// MARK: - Main Product Model

public struct WooCommerceProduct: Decodable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let permalink: String
    public let type: String
    public let status: String?
    public let featured: Bool
    public let description: String?
    public let short_description: String?
    public let sku: String?
    public let price: String
    public let regular_price: String?
    public let sale_price: String?
    public let price_html: String?
    public let on_sale: Bool?
    public let purchasable: Bool?
    public let total_sales: Int?
    public let stock_quantity: Int?
    private let _stock_status: StockStatus?
    public let backorders_allowed: Bool?
    public let sold_individually: Bool?
    public let parent_id: Int?
    public let images: [WooCommerceImage]?
    public let attributes: [WooCommerceAttribute]?
    public let variations: [Int]?
    public let cross_sell_ids: [Int]
    public let categories: [WooCommerceCategoryRef]?
    public var priceRangeDisplay: String? = nil

    enum CodingKeys: String, CodingKey {
        case id, name, slug, permalink, type, status, featured, description, sku, price, on_sale, purchasable, variations, categories
        case short_description, regular_price, sale_price, price_html, total_sales, stock_quantity
        case _stock_status = "stock_status"
        case backorders_allowed, sold_individually, parent_id, images, attributes
        case cross_sell_ids
    }
    
    // Manueller Decoder, um optionale 'cross_sell_ids' sicher zu behandeln.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        permalink = try container.decode(String.self, forKey: .permalink)
        type = try container.decode(String.self, forKey: .type)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        featured = try container.decode(Bool.self, forKey: .featured)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        short_description = try container.decodeIfPresent(String.self, forKey: .short_description)
        sku = try container.decodeIfPresent(String.self, forKey: .sku)
        price = try container.decode(String.self, forKey: .price)
        regular_price = try container.decodeIfPresent(String.self, forKey: .regular_price)
        sale_price = try container.decodeIfPresent(String.self, forKey: .sale_price)
        price_html = try container.decodeIfPresent(String.self, forKey: .price_html)
        on_sale = try container.decodeIfPresent(Bool.self, forKey: .on_sale)
        purchasable = try container.decodeIfPresent(Bool.self, forKey: .purchasable)
        total_sales = try container.decodeIfPresent(Int.self, forKey: .total_sales)
        stock_quantity = try container.decodeIfPresent(Int.self, forKey: .stock_quantity)
        _stock_status = try container.decodeIfPresent(StockStatus.self, forKey: ._stock_status)
        backorders_allowed = try container.decodeIfPresent(Bool.self, forKey: .backorders_allowed)
        sold_individually = try container.decodeIfPresent(Bool.self, forKey: .sold_individually)
        parent_id = try container.decodeIfPresent(Int.self, forKey: .parent_id)
        images = try container.decodeIfPresent([WooCommerceImage].self, forKey: .images)
        attributes = try container.decodeIfPresent([WooCommerceAttribute].self, forKey: .attributes)
        variations = try container.decodeIfPresent([Int].self, forKey: .variations)
        categories = try container.decodeIfPresent([WooCommerceCategoryRef].self, forKey: .categories)
        do {
            cross_sell_ids = try container.decodeIfPresent([Int].self, forKey: .cross_sell_ids) ?? []
        } catch { cross_sell_ids = [] }
    }
    
    public static func == (lhs: WooCommerceProduct, rhs: WooCommerceProduct) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var stock_status: StockStatus { _stock_status ?? .instock }
    public var isPurchasable: Bool { purchasable ?? false }
    public var isOnSale: Bool { on_sale ?? false }
    public var safeImages: [WooCommerceImage] { images ?? [] }
    public var safeAttributes: [WooCommerceAttribute] { attributes ?? [] }
    public var safeCrossSellIDs: [Int] { cross_sell_ids }
    public var safeCategories: [WooCommerceCategoryRef] { categories ?? [] }
}

// MARK: - Product Variation Model

public struct WooCommerceProductVariation: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let price: String
    public let regular_price: String?
    public let sale_price: String?
    public let price_html: String?
    public let on_sale: Bool?
    public let purchasable: Bool?
    public let stock_quantity: Int?
    private let _stock_status: StockStatus?
    public let image: WooCommerceImage?
    public let attributes: [VariationAttribute]?

    enum CodingKeys: String, CodingKey {
         case id, price, regular_price, sale_price, price_html, on_sale, purchasable, stock_quantity, image, attributes
         case _stock_status = "stock_status"
    }
    
    public var stock_status: StockStatus { return _stock_status ?? .instock }
    public var isInStock: Bool { stock_status == .instock }
    public var isPurchasable: Bool { purchasable ?? false }
    public var isOnSale: Bool { on_sale ?? false }
    public var safeAttributes: [VariationAttribute] { attributes ?? [] }
    
    public struct VariationAttribute: Codable, Hashable, Equatable {
        public let id: Int?
        public let name: String?
        public let slug: String?
        public let option: String?
    }
}

// MARK: - Category Model

public struct WooCommerceCategory: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let parent: Int
    public let description: String?
    public let display: String?
    public let image: WooCommerceImage?
    public let menu_order: Int?
    public let count: Int
}

// MARK: - API Response Wrapper

public struct WooCommerceProductsResponseContainer: Decodable {
    public let products: [WooCommerceProduct]
    public let totalPages: Int
    public let totalCount: Int
}