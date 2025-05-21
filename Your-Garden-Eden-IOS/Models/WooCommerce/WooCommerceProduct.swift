//
//  WooCommerceProduct.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 21.05.25.
//


import Foundation

struct WooCommerceProduct: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let slug: String
    let permalink: String
    let dateCreated: String
    let dateCreatedGmt: String
    let dateModified: String
    let dateModifiedGmt: String
    let type: String
    let status: String
    let featured: Bool
    let catalogVisibility: String
    let description: String
    let shortDescription: String
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
    let purchasable: Bool
    let totalSales: Int
    let virtual: Bool
    let downloadable: Bool
    let downloads: [WooCommerceProductDownload]?
    let downloadLimit: Int?
    let downloadExpiry: Int?
    let externalUrl: String?
    let buttonText: String?
    let taxStatus: String
    let taxClass: String?
    let manageStock: Bool
    let stockQuantity: Int?
    let stockStatus: String
    let backorders: String
    let backordersAllowed: Bool
    let backordered: Bool
    let lowStockAmount: Int?
    let soldIndividually: Bool
    let weight: String?
    let dimensions: WooCommerceProductDimension
    let shippingRequired: Bool
    let shippingTaxable: Bool
    let shippingClass: String?
    let shippingClassId: Int
    let reviewsAllowed: Bool
    let averageRating: String
    let ratingCount: Int
    let relatedIds: [Int]
    let upsellIds: [Int]
    let crossSellIds: [Int]
    let parentId: Int
    let purchaseNote: String?
    let categories: [WooCommerceCategoryRef]
    let tags: [WooCommerceTagRef] // Stelle sicher, dass WooCommerceTagRef.placeholder existiert, wenn du es hier verwendest
    let images: [WooCommerceImage]
    let attributes: [WooCommerceAttribute] // Stelle sicher, dass WooCommerceAttribute.placeholder existiert
    let defaultAttributes: [WooCommerceDefaultAttribute] // Stelle sicher, dass WooCommerceDefaultAttribute.placeholder existiert
    let variations: [Int]
    let groupedProducts: [Int]?
    let menuOrder: Int
    let metaData: [WooCommerceMetaData] // Stelle sicher, dass WooCommerceMetaData.placeholder existiert

    enum CodingKeys: String, CodingKey {
        case id, name, slug, permalink, type, status, featured, description, sku, price
        case dateCreated = "date_created"
        case dateCreatedGmt = "date_created_gmt"
        case dateModified = "date_modified"
        case dateModifiedGmt = "date_modified_gmt"
        case catalogVisibility = "catalog_visibility"
        case shortDescription = "short_description"
        case regularPrice = "regular_price"
        case salePrice = "sale_price"
        case priceHtml = "price_html"
        case dateOnSaleFrom = "date_on_sale_from"
        case dateOnSaleFromGmt = "date_on_sale_from_gmt"
        case dateOnSaleTo = "date_on_sale_to"
        case dateOnSaleToGmt = "date_on_sale_to_gmt"
        case onSale = "on_sale"
        case purchasable
        case totalSales = "total_sales"
        case virtual, downloadable, downloads
        case downloadLimit = "download_limit"
        case downloadExpiry = "download_expiry"
        case externalUrl = "external_url"
        case buttonText = "button_text"
        case taxStatus = "tax_status"
        case taxClass = "tax_class"
        case manageStock = "manage_stock"
        case stockQuantity = "stock_quantity"
        case stockStatus = "stock_status"
        case backorders
        case backordersAllowed = "backorders_allowed"
        case backordered
        case lowStockAmount = "low_stock_amount"
        case soldIndividually = "sold_individually"
        case weight, dimensions
        case shippingRequired = "shipping_required"
        case shippingTaxable = "shipping_taxable"
        case shippingClass = "shipping_class"
        case shippingClassId = "shipping_class_id"
        case reviewsAllowed = "reviews_allowed"
        case averageRating = "average_rating"
        case ratingCount = "rating_count"
        case relatedIds = "related_ids"
        case upsellIds = "upsell_ids"
        case crossSellIds = "cross_sell_ids"
        case parentId = "parent_id"
        case purchaseNote = "purchase_note"
        case categories, tags, images, attributes
        case defaultAttributes = "default_attributes"
        case variations
        case groupedProducts = "grouped_products"
        case menuOrder = "menu_order"
        case metaData = "meta_data"
    }

    // Statische Placeholder-Instanz für Previews
    static var placeholder: WooCommerceProduct {
        WooCommerceProduct(
            id: 1, name: "Beispiel Produkt", slug: "beispiel-produkt", permalink: "",
            dateCreated: "", dateCreatedGmt: "", dateModified: "", dateModifiedGmt: "",
            type: "simple", status: "publish", featured: false, catalogVisibility: "visible",
            description: "Ein tolles Beispielprodukt.", shortDescription: "Beispiel.", sku: "BSP-001",
            price: "49.99", regularPrice: "49.99", salePrice: nil, priceHtml: "€49.99",
            dateOnSaleFrom: nil, dateOnSaleFromGmt: nil, dateOnSaleTo: nil, dateOnSaleToGmt: nil,
            onSale: false, purchasable: true, totalSales: 0,
            virtual: false, downloadable: false, downloads: [], downloadLimit: nil, downloadExpiry: nil,
            externalUrl: nil, buttonText: nil, taxStatus: "taxable", taxClass: "",
            manageStock: false, stockQuantity: nil, stockStatus: "instock",
            backorders: "no", backordersAllowed: false, backordered: false, lowStockAmount: nil,
            soldIndividually: false, weight: "1kg", dimensions: .placeholder, // Nutzt den Placeholder von WooCommerceProductDimension
            shippingRequired: true, shippingTaxable: true, shippingClass: "", shippingClassId: 0,
            reviewsAllowed: true, averageRating: "0", ratingCount: 0,
            relatedIds: [], upsellIds: [], crossSellIds: [], parentId: 0, purchaseNote: "",
            categories: [WooCommerceCategoryRef.placeholder], // Nutzt den Placeholder
            tags: [], // Benötigt WooCommerceTagRef.placeholder, wenn nicht leer
            images: [WooCommerceImage.placeholder], // Nutzt den Placeholder
            attributes: [], // Benötigt WooCommerceAttribute.placeholder, wenn nicht leer
            defaultAttributes: [], // Benötigt WooCommerceDefaultAttribute.placeholder, wenn nicht leer
            variations: [], groupedProducts: [], menuOrder: 0, metaData: [] // Benötigt WooCommerceMetaData.placeholder, wenn nicht leer
        )
    }
}

// WooCommerceProductDownload (bereits von dir gezeigt, sollte auch einen .placeholder haben, wenn in Product.placeholder.downloads verwendet)
// ...
