// Path: Your-Garden-Eden-IOS/Core/Models/AppModels.swift

import Foundation

// MARK: - EINZIGE QUELLE DER WAHRHEIT FÜR DATENMODELLE

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

struct ProductVariationData: Hashable {
    let product: WooCommerceProduct
    let variations: [WooCommerceProductVariation]
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
        case .serverError(_, let message, let errorCode):
            return "Serverfehler: \(message ?? "Unbekannt") (\(errorCode ?? "N/A"))"
        case .decodingError: return "Fehler beim Verarbeiten der Server-Antwort."
        case .underlying(let error): return "Ein unerwarteter Fehler ist aufgetreten: \(error.localizedDescription)"
        }
    }
    
    var localizedDescriptionForUser: String {
        switch self {
        case .serverError(_, let message, _):
            return message ?? "Ein Serverfehler ist aufgetreten. Bitte versuchen Sie es später erneut."
        case .notAuthenticated:
            return "Sie sind nicht angemeldet."
        default:
            return "Ein unbekannter Fehler ist aufgetreten. Bitte überprüfen Sie Ihre Internetverbindung."
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

// MARK: - WooCommerce Models
enum ProductType: String, Codable, Hashable {
    case simple, variable, grouped, external
}
enum StockStatus: String, Codable, Hashable {
    case instock, outofstock, onbackorder
}

struct WooCommerceProductsResponseContainer {
    let products: [WooCommerceProduct]
    let totalPages: Int
    let totalCount: Int
}

struct WooCommerceProduct: Identifiable, Hashable, Equatable, Codable {
    let id: Int
    let name: String
    let slug: String
    let parentId: Int
    let type: ProductType
    let description: String
    let price: String
    let priceHtml: String?
    let onSale: Bool
    let purchasable: Bool
    let stockStatus: StockStatus
    let soldIndividually: Bool
    let images: [WooCommerceImage]
    let attributes: [WooCommerceAttribute]
    let variations: [Int]
    let crossSellIds: [Int]

    enum CodingKeys: String, CodingKey {
        case id, name, slug, type, description, price, purchasable, images, attributes, variations
        case parentId = "parent_id", priceHtml = "price_html", onSale = "on_sale"
        case stockStatus = "stock_status", soldIndividually = "sold_individually", crossSellIds = "cross_sell_ids"
    }
}

struct WooCommerceProductVariation: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let price: String
    let priceHtml: String?
    let stockStatus: StockStatus
    let image: WooCommerceImage?
    let attributes: [VariationAttribute]

    struct VariationAttribute: Codable, Hashable, Equatable {
        let name: String, option: String
    }
    enum CodingKeys: String, CodingKey {
        case id, price, image, attributes
        case priceHtml = "price_html", stockStatus = "stock_status"
    }
    var isInStock: Bool { self.stockStatus == .instock }
}

struct WooCommerceImage: Codable, Identifiable, Hashable, Equatable {
    let id: Int, src: String
}
struct WooCommerceAttribute: Codable, Identifiable, Hashable, Equatable {
    let id: Int, name: String, variation: Bool, options: [String]
}
struct WooCommerceCategory: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let slug: String
    let parent: Int
    let description: String
    let display: String
    let image: WooCommerceImage?
    let menuOrder: Int
    let count: Int
}

// MARK: - WooCommerce Store API (Cart) Models
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
    
    struct ItemTotals: Codable, Equatable, Hashable { let lineTotal: String }
    struct CartImage: Codable, Equatable, Hashable { let id: Int, src: String, thumbnail: String }
    
    enum CodingKeys: String, CodingKey {
        case key, id, quantity, name, totals, images
    }
}

struct Totals: Codable, Equatable, Hashable {
    let totalPrice: String
    let currencySymbol: String
    
    var totalPriceFormatted: String {
        return PriceFormatter.formatPrice(totalPrice, currencySymbol: currencySymbol)
    }
    
    enum CodingKeys: String, CodingKey {
        case totalPrice = "total_price", currencySymbol = "currency_symbol"
    }
}
