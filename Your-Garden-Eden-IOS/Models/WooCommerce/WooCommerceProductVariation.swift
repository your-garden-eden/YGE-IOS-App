// YGE-IOS-App/Core/Models/WooCommerce/CoreAPI/WooCommerceProductVariation.swift
import Foundation

// --- MODIFIZIERT ---
// Wir haben mehrere Eigenschaften zu Optionalen (z.B. String?) gemacht,
// um den "Decoding"-Fehler zu beheben. Die App kann nun `null`-Werte vom
// Server für diese Felder korrekt verarbeiten.

struct WooCommerceProductVariation: Codable, Identifiable, Hashable {
    let id: Int
    // MODIFIZIERT: Diese Felder können null sein.
    let dateCreated: String?
    let dateCreatedGmt: String?
    let dateModified: String?
    let dateModifiedGmt: String?
    let description: String?
    
    let permalink: String
    let sku: String
    let price: String
    let regularPrice: String
    let salePrice: String?
    let priceHtml: String?
    let dateOnSaleFrom: String?
    let dateOnSaleFromGmt: String?
    let dateOnSaleTo: String?
    let dateOnSaleToGmt: String?
    let onSale: Bool
    let status: String
    let purchasable: Bool
    let virtual: Bool
    let downloadable: Bool
    let taxStatus: String
    let taxClass: String?
    let manageStock: Bool
    let stockQuantity: Int?
    let stockStatus: StockStatus
    let backorders: String
    let backordersAllowed: Bool
    let backordered: Bool
    let lowStockAmount: Int?
    let weight: String?
    let dimensions: WooCommerceProductDimension
    let shippingClass: String?
    let shippingClassId: Int
    let image: WooCommerceImage?
    let attributes: [VariationAttribute]
    let menuOrder: Int
    let metaData: [WooCommerceMetaData]

    struct VariationAttribute: Codable, Hashable {
        let id: Int
        let name: String
        let option: String
        let slug: String?
    }

    enum CodingKeys: String, CodingKey {
        case id, description, permalink, sku, price, virtual, downloadable, attributes
        case dateCreated = "date_created"
        case dateCreatedGmt = "date_created_gmt"
        case dateModified = "date_modified"
        case dateModifiedGmt = "date_modified_gmt"
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
        case priceHtml = "price_html"
        case dateOnSaleFrom = "date_on_sale_from"
        case dateOnSaleFromGmt = "date_on_sale_from_gmt"
        case dateOnSaleTo = "date_on_sale_to"
        case dateOnSaleToGmt = "date_on_sale_to_gmt"
        case onSale = "on_sale"
        case status, purchasable
        case taxStatus = "tax_status"
        case taxClass = "tax_class"
        case manageStock = "manage_stock"
        case stockQuantity = "stock_quantity"
        case stockStatus = "stock_status"
        case backorders
        case backordersAllowed = "backorders_allowed"
        case backordered
        case lowStockAmount = "low_stock_amount"
        case weight, dimensions
        case shippingClass = "shipping_class"
        case shippingClassId = "shipping_class_id"
        case image
        case menuOrder = "menu_order"
        case metaData = "meta_data"
    }
}

// HINWEIS: Diese Erweiterung bleibt unverändert, sie war bereits korrekt.
extension WooCommerceProductVariation.VariationAttribute {
    func optionAsSlug() -> String {
        if let slug = self.slug, !slug.trimmingCharacters(in: .whitespaces).isEmpty {
            return slug
        }
        let baseSlug = option.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        var finalSlug = baseSlug.components(separatedBy: allowedCharacters.inverted).joined()
        while finalSlug.contains("--") {
            finalSlug = finalSlug.replacingOccurrences(of: "--", with: "-")
        }
        return finalSlug
    }
}
