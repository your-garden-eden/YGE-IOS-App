// Path: Your-Garden-Eden-IOS/Core/Models/AppModels.swift
// VERSION 2.5 (FINAL - Price Range Ready)

import Foundation

// MARK: - Application-Specific Models
struct UserModel: Codable, Identifiable {
    let id: Int
    let displayName: String
    let email: String
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

// MARK: - Custom Errors
enum WooCommerceAPIError: Error, LocalizedError {
    case invalidURL, noData, productNotFound, notAuthenticated
    case serverError(statusCode: Int, message: String?, errorCode: String?)
    case decodingError(Error)
    case underlying(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Die API-Adresse ist ungültig."
        case .noData: return "Keine Daten vom Server erhalten."
        case .productNotFound: return "Das Produkt wurde nicht gefunden."
        case .notAuthenticated: return "Authentifizierung fehlgeschlagen. Bitte erneut anmelden."
        case .serverError(let st, let msg, let code): return "Serverfehler (\(st)): \(msg ?? "Unbekannt") (\(code ?? "N/A"))"
        case .decodingError(let err): return "Fehler beim Verarbeiten der Server-Antwort: \(err.localizedDescription)"
        case .underlying(let err): return "Ein unerwarteter Fehler ist aufgetreten: \(err.localizedDescription)"
        }
    }
    
    public var localizedDescriptionForUser: String {
        switch self {
        case .invalidURL, .noData, .decodingError: return "Ein Problem mit der Serververbindung ist aufgetreten."
        case .productNotFound: return "Das angeforderte Produkt konnte nicht gefunden werden."
        case .notAuthenticated: return "Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an."
        case .serverError: return "Ein Fehler auf dem Server ist aufgetreten. Unser Team wurde informiert."
        case .underlying: return "Ein unerwarteter Fehler ist aufgetreten. Bitte starten Sie die App neu."
        }
    }
}

struct WooCommerceErrorResponse: Decodable {
    let code: String
    let message: String
}
struct WooCommerceStoreErrorResponse: Decodable {
    let code: String
    let message: String
}

// MARK: - WooCommerce Enums & Models
enum StockStatus: String, Codable, Hashable {
    case instock
    case outofstock
    case onbackorder
}

struct WooCommerceCategoryRef: Codable, Hashable, Equatable {
    let id: Int
    let name: String
    let slug: String
}

struct WooCommerceImage: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let src: String
    let name: String
    let alt: String
}

struct WooCommerceAttribute: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let variation: Bool
    let options: [String]
}

struct WooCommerceProduct: Identifiable, Hashable, Equatable, Decodable {
    let id: Int
    let name: String
    let slug: String
    let permalink: String
    let type: String
    let status: String?
    let featured: Bool
    let description: String?
    let short_description: String?
    let sku: String?
    let price: String
    let regular_price: String?
    let sale_price: String?
    let price_html: String?
    let on_sale: Bool?
    let purchasable: Bool?
    let total_sales: Int?
    let stock_quantity: Int?
    
    private let _stock_status: StockStatus?
    
    let backorders_allowed: Bool?
    let sold_individually: Bool?
    let parent_id: Int?
    let images: [WooCommerceImage]?
    let attributes: [WooCommerceAttribute]?
    let variations: [Int]?
    let cross_sell_ids: [Int]
    let categories: [WooCommerceCategoryRef]?

    // ===================================================================
    // **DAS ENTSCHEIDENDE NEUE FELD**
    // Eine 'var', um die berechnete Preisspanne später zu speichern.
    // ===================================================================
    var priceRangeDisplay: String? = nil

    enum CodingKeys: String, CodingKey {
        case id, name, slug, permalink, type, status, featured, description, sku, price, on_sale, purchasable, variations, categories
        case short_description, regular_price, sale_price, price_html, total_sales, stock_quantity
        case _stock_status = "stock_status"
        case backorders_allowed, sold_individually, parent_id, images, attributes
        case cross_sell_ids
    }
    
    init(from decoder: Decoder) throws {
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
        } catch {
            print("🔴 DECODING WARNING: Konnte 'cross_sell_ids' nicht als [Int] dekodieren. Setze auf leeres Array. Fehler: \(error)")
            cross_sell_ids = []
        }
    }

    var stock_status: StockStatus { _stock_status ?? .instock }
    var isPurchasable: Bool { purchasable ?? false }
    var isOnSale: Bool { on_sale ?? false }
    var safeImages: [WooCommerceImage] { images ?? [] }
    var safeAttributes: [WooCommerceAttribute] { attributes ?? [] }
    var safeCrossSellIDs: [Int] { cross_sell_ids }
    var safeCategories: [WooCommerceCategoryRef] { categories ?? [] }
}


struct WooCommerceProductVariation: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let price: String
    let regular_price: String?
    let sale_price: String?
    let price_html: String?
    let on_sale: Bool?
    let purchasable: Bool?
    let stock_quantity: Int?
    
    private let _stock_status: StockStatus?
    
    let image: WooCommerceImage?
    let attributes: [VariationAttribute]?

    enum VariationCodingKeys: String, CodingKey {
         case id, price, regular_price, sale_price, price_html, on_sale, purchasable, stock_quantity, image, attributes
         case _stock_status = "stock_status"
    }
    
    var stock_status: StockStatus {
        return _stock_status ?? .instock
    }

    var isInStock: Bool { stock_status == .instock }
    var isPurchasable: Bool { purchasable ?? false }
    var isOnSale: Bool { on_sale ?? false }
    var safeAttributes: [VariationAttribute] { attributes ?? [] }
    
    struct VariationAttribute: Codable, Hashable, Equatable {
        let id: Int?
        let name: String?
        let slug: String?
        let option: String?
    }
}

struct WooCommerceCategory: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let slug: String
    let parent: Int
    let description: String?
    let display: String?
    let image: WooCommerceImage?
    let menu_order: Int?
    let count: Int
}

struct WooCommerceProductsResponseContainer: Decodable {
    let products: [WooCommerceProduct]
    let totalPages: Int
    let totalCount: Int
}

struct WooCommerceStoreCart: Codable {
    let items: [Item]?
    let totals: Totals?
    
    var safeItems: [Item] { items ?? [] }
}

struct Item: Codable, Identifiable, Equatable, Hashable {
    let key: String
    let id: Int
    let quantity: Int
    let name: String
    let totals: ItemTotals
    let images: [CartImage]
    
    struct ItemTotals: Codable, Equatable, Hashable {
        let lineTotal: String
        
        enum CodingKeys: String, CodingKey {
            case lineTotal = "line_total"
        }
    }
    
    struct CartImage: Codable, Equatable, Hashable {
        let id: Int
        let src: String
        let thumbnail: String
    }
}

struct Totals: Codable, Equatable, Hashable {
    let totalPrice: String
    let currencySymbol: String
    
    var totalPriceFormatted: String {
        PriceFormatter.formatPrice(totalPrice, currencySymbol: currencySymbol)
    }
    
    enum CodingKeys: String, CodingKey {
        case totalPrice = "total_price"
        case currencySymbol = "currency_symbol"
    }
}

struct YGEWishlist: Codable, Hashable {
    let items: [YGEWishlistItem]
}

struct YGEWishlistItem: Codable, Hashable, Identifiable {
    var id: String { "\(productId)-\(variationId ?? 0)" }
    let productId: Int
    let variationId: Int?
    let addedAt: String
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case variationId = "variation_id"
        case addedAt = "added_at"
    }
}
