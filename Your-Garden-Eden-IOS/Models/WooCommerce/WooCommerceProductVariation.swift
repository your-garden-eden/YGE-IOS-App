// YGE-IOS-App/Core/Models/WooCommerce/CoreAPI/WooCommerceProductVariation.swift
import Foundation

struct WooCommerceProductVariation: Codable, Identifiable, Hashable {
    let id: Int
    let dateCreated: String
    let dateCreatedGmt: String
    let dateModified: String
    let dateModifiedGmt: String
    let description: String
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
    let status: String // z.B. "publish" - könnte auch ein Enum werden
    let purchasable: Bool
    let virtual: Bool
    let downloadable: Bool
    // downloads, downloadLimit, downloadExpiry bei Bedarf hinzufügen
    let taxStatus: String
    let taxClass: String?
    let manageStock: Bool
    let stockQuantity: Int?
    let stockStatus: StockStatus // Verwendet das Enum
    let backorders: String
    let backordersAllowed: Bool
    let backordered: Bool
    let lowStockAmount: Int?
    let weight: String?
    let dimensions: WooCommerceProductDimension // Annahme: WooCommerceProductDimension ist definiert
    let shippingClass: String?
    let shippingClassId: Int
    let image: WooCommerceImage?
    let attributes: [VariationAttribute]
    let menuOrder: Int
    let metaData: [WooCommerceMetaData] // Annahme: WooCommerceMetaData ist definiert

    struct VariationAttribute: Codable, Hashable {
        let id: Int
        let name: String
        let option: String
        let slug: String? // Hinzugefügt, da es oft von der API kommt und nützlich ist
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
        case weight, dimensions // dimensions braucht ein eigenes Struct
        case shippingClass = "shipping_class"
        case shippingClassId = "shipping_class_id"
        case image
        case menuOrder = "menu_order"
        case metaData = "meta_data"
    }
}
