
// DATEI: WooCommerceModels.swift
// PFAD: Core/Models/WooCommerceModels.swift
// VERSION: 3.2 (VOLLSTÄNDIG & GEPANZERT)
// STATUS: Alle Modelle gehärtet und vollständig ausgeschrieben.

import Foundation

// MARK: - Enums
public enum StockStatus: String, Codable, Hashable, Equatable {
    case instock
    case outofstock
    case onbackorder
}

// MARK: - Product & Category Models

public struct WooCommerceProduct: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let type: String
    public let status: String
    public let purchasable: Bool?
    public let onSale: Bool?
    public let price: String
    public let regularPrice: String
    public let salePrice: String
    public let priceHTML: String?
    public let stockStatus: StockStatus?
    public let totalSales: Int?
    public let dateModified: String?
    public let soldIndividually: Bool?
    public let description: String?
    public let shortDescription: String?
    public let images: [WooCommerceImage]?
    public let attributes: [WooCommerceAttribute]?
    public let crossSellIDs: [Int]?
    public let relatedIDs: [Int]?
    public let parentID: Int?
    
    // --- Computed Properties for Safety & Convenience ---
    public var safeImages: [WooCommerceImage] { images ?? [] }
    public var safeAttributes: [WooCommerceAttribute] { attributes ?? [] }
    public var safeCrossSellIDs: [Int] { crossSellIDs ?? [] }
    public var safeRelatedIDs: [Int] { relatedIDs ?? [] }
    public var priceValue: Double { Double(price) ?? 0.0 }
    public var regularPriceValue: Double { Double(regularPrice) ?? 0.0 }
    public var salePriceValue: Double { Double(salePrice) ?? 0.0 }
    
    // --- Mutable property for ViewModel enhancements ---
    public var priceRangeDisplay: String?

    // --- Custom Decoder for Hardening ---
    enum CodingKeys: String, CodingKey {
        case id, name, slug, type, status, purchasable, price
        case on_sale = "on_sale"
        case regular_price, sale_price
        case price_html, stock_status
        case total_sales
        case date_modified
        case sold_individually, description, short_description
        case images, attributes
        case cross_sell_ids, related_ids
        case parent_id
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        slug = try container.decodeIfPresent(String.self, forKey: .slug) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "simple"
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "private"
        purchasable = try container.decodeIfPresent(Bool.self, forKey: .purchasable)
        onSale = try container.decodeIfPresent(Bool.self, forKey: .on_sale)
        
        price = try container.decodeIfPresent(String.self, forKey: .price) ?? ""
        regularPrice = try container.decodeIfPresent(String.self, forKey: .regular_price) ?? ""
        salePrice = try container.decodeIfPresent(String.self, forKey: .sale_price) ?? ""
        priceHTML = try container.decodeIfPresent(String.self, forKey: .price_html)
        
        stockStatus = try container.decodeIfPresent(StockStatus.self, forKey: .stock_status)
        soldIndividually = try container.decodeIfPresent(Bool.self, forKey: .sold_individually)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        shortDescription = try container.decodeIfPresent(String.self, forKey: .short_description)
        
        if let salesInt = try? container.decodeIfPresent(Int.self, forKey: .total_sales) {
            totalSales = salesInt
        } else if let salesString = try? container.decodeIfPresent(String.self, forKey: .total_sales) {
            totalSales = Int(salesString)
        } else {
            totalSales = nil
        }
        
        dateModified = try container.decodeIfPresent(String.self, forKey: .date_modified)
        
        images = try container.decodeIfPresent([WooCommerceImage].self, forKey: .images)
        attributes = try container.decodeIfPresent([WooCommerceAttribute].self, forKey: .attributes)
        crossSellIDs = try container.decodeIfPresent([Int].self, forKey: .cross_sell_ids)
        relatedIDs = try container.decodeIfPresent([Int].self, forKey: .related_ids)
        parentID = try container.decodeIfPresent(Int.self, forKey: .parent_id)
    }
    
    public func encode(to encoder: Encoder) throws {
        // Implement if needed for sending data back to the server
    }
}

public struct WooCommerceCategory: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let image: WooCommerceImage?
}

public struct WooCommerceImage: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let src: String
    public let name: String?
    public let alt: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Das Datum kann fehlerhaft sein, ID wird aus anderen Quellen bezogen oder als 0 gesetzt.
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        src = try container.decodeIfPresent(String.self, forKey: .src) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name)
        alt = try container.decodeIfPresent(String.self, forKey: .alt)
    }
}

public struct WooCommerceProductVariation: Decodable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let price: String
    public let regular_price: String
    public let sale_price: String
    public let stock_status: StockStatus?
    public let image: WooCommerceImage?
    public let attributes: [WooCommerceAttribute]?
    
    public var safeAttributes: [WooCommerceAttribute] { attributes ?? [] }
    public var isPurchasable: Bool { stock_status != .outofstock }
    public var isInStock: Bool { stock_status == .instock }
    public var priceValue: Double { Double(price) ?? 0.0 }
    
    enum CodingKeys: String, CodingKey {
        case id, price, regular_price, sale_price, stock_status, image, attributes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        price = try container.decodeIfPresent(String.self, forKey: .price) ?? ""
        regular_price = try container.decodeIfPresent(String.self, forKey: .regular_price) ?? ""
        sale_price = try container.decodeIfPresent(String.self, forKey: .sale_price) ?? ""
        stock_status = try container.decodeIfPresent(StockStatus.self, forKey: .stock_status)
        image = try container.decodeIfPresent(WooCommerceImage.self, forKey: .image)
        attributes = try container.decodeIfPresent([WooCommerceAttribute].self, forKey: .attributes)
    }
}


public struct WooCommerceAttribute: Codable, Hashable, Equatable {
    public let name: String?
    public let option: String?
    public let variation: Bool
    public let options: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, option, variation, options
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        option = try container.decodeIfPresent(String.self, forKey: .option)
        variation = try container.decodeIfPresent(Bool.self, forKey: .variation) ?? false
        options = try container.decodeIfPresent([String].self, forKey: .options) ?? []
    }
}

public struct WooCommerceProductsResponseContainer: Decodable {
    public let products: [WooCommerceProduct]
    public let totalPages: Int
}

// MARK: - Attribute Models
public struct WooCommerceAttributeDefinition: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let type: String
}

public struct WooCommerceAttributeTerm: Codable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let count: Int
}

// MARK: - Filter Parameters
public struct ProductFilterParameters {
    var categoryId: Int?
    var onSale: Bool?
    var featured: Bool?
    var searchQuery: String?
    var include: [Int]?
    var stockStatus: StockStatus?
    var productType: String?
    var orderBy: String?
    var order: String?
}

