import Foundation

struct WooCommerceProductVariationAttribute: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let slug: String?
    let option: String
}

struct WooCommerceProductVariation: Codable, Identifiable, Hashable, Equatable {
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
    let status: String
    let purchasable: Bool
    let virtual: Bool
    let downloadable: Bool
    let downloads: [WooCommerceProductDownload]?
    let downloadLimit: Int?
    let downloadExpiry: Int?
    let taxStatus: String
    let taxClass: String?
    let manageStock: Bool
    let stockQuantity: Int?
    let stockStatus: String
    let backorders: String
    let backordersAllowed: Bool
    let backordered: Bool
    let lowStockAmount: Int?
    let weight: String?
    let dimensions: WooCommerceProductDimension
    let shippingClass: String?
    let shippingClassId: Int
    let image: WooCommerceImage?
    let attributes: [WooCommerceProductVariationAttribute]
    let menuOrder: Int
    let metaData: [WooCommerceMetaData]

    enum CodingKeys: String, CodingKey {
        case id, description, permalink, sku, price, status, purchasable, virtual, downloadable, downloads, attributes
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
        case downloadLimit = "download_limit"
        case downloadExpiry = "download_expiry"
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
