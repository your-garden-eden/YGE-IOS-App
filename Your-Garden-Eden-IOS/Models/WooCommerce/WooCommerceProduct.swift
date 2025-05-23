// YGE-IOS-App/Core/Models/WooCommerce/CoreAPI/WooCommerceProduct.swift
import Foundation

struct WooCommerceProduct: Identifiable, Hashable, Codable { // Codable wird manuell implementiert
    let id: Int
    let name: String
    let slug: String
    let permalink: String
    let dateCreated: String
    let dateCreatedGmt: String
    let dateModified: String
    let dateModifiedGmt: String
    let type: ProductType
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
    let externalUrl: String?
    let buttonText: String?
    let taxStatus: String
    let taxClass: String?
    let manageStock: Bool
    let stockQuantity: Int?
    let stockStatus: StockStatus
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
    let tags: [WooCommerceTagRef]
    let images: [WooCommerceImage]
    let attributes: [WooCommerceAttribute]
    let defaultAttributes: [WooCommerceDefaultAttribute]
    let variations: [Int]
    let groupedProducts: [Int]?
    let menuOrder: Int
    let metaData: [WooCommerceMetaData]

    enum CodingKeys: String, CodingKey {
        case id, name, slug, permalink, type, status, featured, description, sku, price, virtual, downloadable, dimensions, tags, images, attributes, variations, weight
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
        case categories
        case defaultAttributes = "default_attributes"
        case groupedProducts = "grouped_products"
        case menuOrder = "menu_order"
        case metaData = "meta_data"
    }

    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        permalink = try container.decode(String.self, forKey: .permalink)
        dateCreated = try container.decode(String.self, forKey: .dateCreated)
        dateCreatedGmt = try container.decode(String.self, forKey: .dateCreatedGmt)
        dateModified = try container.decode(String.self, forKey: .dateModified)
        dateModifiedGmt = try container.decode(String.self, forKey: .dateModifiedGmt)
        type = try container.decode(ProductType.self, forKey: .type)
        status = try container.decode(String.self, forKey: .status)
        featured = try container.decode(Bool.self, forKey: .featured)
        catalogVisibility = try container.decode(String.self, forKey: .catalogVisibility)
        description = try container.decode(String.self, forKey: .description)
        shortDescription = try container.decode(String.self, forKey: .shortDescription)
        sku = try container.decode(String.self, forKey: .sku)
        price = try container.decode(String.self, forKey: .price)
        regularPrice = try container.decode(String.self, forKey: .regularPrice)
        salePrice = try container.decodeIfPresent(String.self, forKey: .salePrice)
        priceHtml = try container.decodeIfPresent(String.self, forKey: .priceHtml)
        dateOnSaleFrom = try container.decodeIfPresent(String.self, forKey: .dateOnSaleFrom)
        dateOnSaleFromGmt = try container.decodeIfPresent(String.self, forKey: .dateOnSaleFromGmt)
        dateOnSaleTo = try container.decodeIfPresent(String.self, forKey: .dateOnSaleTo)
        dateOnSaleToGmt = try container.decodeIfPresent(String.self, forKey: .dateOnSaleToGmt)
        onSale = try container.decode(Bool.self, forKey: .onSale)
        purchasable = try container.decode(Bool.self, forKey: .purchasable)
        totalSales = try container.decode(Int.self, forKey: .totalSales)
        virtual = try container.decode(Bool.self, forKey: .virtual)
        downloadable = try container.decode(Bool.self, forKey: .downloadable)
        externalUrl = try container.decodeIfPresent(String.self, forKey: .externalUrl)
        buttonText = try container.decodeIfPresent(String.self, forKey: .buttonText)
        taxStatus = try container.decode(String.self, forKey: .taxStatus)
        taxClass = try container.decodeIfPresent(String.self, forKey: .taxClass)
        manageStock = try container.decode(Bool.self, forKey: .manageStock)
        stockQuantity = try container.decodeIfPresent(Int.self, forKey: .stockQuantity)
        stockStatus = try container.decode(StockStatus.self, forKey: .stockStatus)
        backorders = try container.decode(String.self, forKey: .backorders)
        backordersAllowed = try container.decode(Bool.self, forKey: .backordersAllowed)
        backordered = try container.decode(Bool.self, forKey: .backordered)
        lowStockAmount = try container.decodeIfPresent(Int.self, forKey: .lowStockAmount)
        soldIndividually = try container.decode(Bool.self, forKey: .soldIndividually)
        weight = try container.decodeIfPresent(String.self, forKey: .weight)
        dimensions = try container.decode(WooCommerceProductDimension.self, forKey: .dimensions)
        shippingRequired = try container.decode(Bool.self, forKey: .shippingRequired)
        shippingTaxable = try container.decode(Bool.self, forKey: .shippingTaxable)
        shippingClass = try container.decodeIfPresent(String.self, forKey: .shippingClass)
        shippingClassId = try container.decode(Int.self, forKey: .shippingClassId)
        reviewsAllowed = try container.decode(Bool.self, forKey: .reviewsAllowed)
        averageRating = try container.decode(String.self, forKey: .averageRating)
        ratingCount = try container.decode(Int.self, forKey: .ratingCount)
        relatedIds = (try? container.decodeIfPresent([Int].self, forKey: .relatedIds)) ?? []
        upsellIds = (try? container.decodeIfPresent([Int].self, forKey: .upsellIds)) ?? []
        crossSellIds = (try? container.decodeIfPresent([Int].self, forKey: .crossSellIds)) ?? []
        parentId = try container.decode(Int.self, forKey: .parentId)
        purchaseNote = try container.decodeIfPresent(String.self, forKey: .purchaseNote)
        categories = (try? container.decodeIfPresent([WooCommerceCategoryRef].self, forKey: .categories)) ?? []
        tags = (try? container.decodeIfPresent([WooCommerceTagRef].self, forKey: .tags)) ?? []
        images = (try? container.decodeIfPresent([WooCommerceImage].self, forKey: .images)) ?? []
        attributes = (try? container.decodeIfPresent([WooCommerceAttribute].self, forKey: .attributes)) ?? []
        defaultAttributes = (try? container.decodeIfPresent([WooCommerceDefaultAttribute].self, forKey: .defaultAttributes)) ?? []
        variations = (try? container.decodeIfPresent([Int].self, forKey: .variations)) ?? []
        groupedProducts = try container.decodeIfPresent([Int].self, forKey: .groupedProducts)
        menuOrder = try container.decode(Int.self, forKey: .menuOrder)
        metaData = (try? container.decodeIfPresent([WooCommerceMetaData].self, forKey: .metaData)) ?? []
    }

    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(slug, forKey: .slug)
        try container.encode(permalink, forKey: .permalink)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateCreatedGmt, forKey: .dateCreatedGmt)
        try container.encode(dateModified, forKey: .dateModified)
        try container.encode(dateModifiedGmt, forKey: .dateModifiedGmt)
        try container.encode(type, forKey: .type)
        try container.encode(status, forKey: .status)
        try container.encode(featured, forKey: .featured)
        try container.encode(catalogVisibility, forKey: .catalogVisibility)
        try container.encode(description, forKey: .description)
        try container.encode(shortDescription, forKey: .shortDescription)
        try container.encode(sku, forKey: .sku)
        try container.encode(price, forKey: .price)
        try container.encode(regularPrice, forKey: .regularPrice)
        try container.encodeIfPresent(salePrice, forKey: .salePrice)
        try container.encodeIfPresent(priceHtml, forKey: .priceHtml)
        try container.encodeIfPresent(dateOnSaleFrom, forKey: .dateOnSaleFrom)
        try container.encodeIfPresent(dateOnSaleFromGmt, forKey: .dateOnSaleFromGmt)
        try container.encodeIfPresent(dateOnSaleTo, forKey: .dateOnSaleTo)
        try container.encodeIfPresent(dateOnSaleToGmt, forKey: .dateOnSaleToGmt)
        try container.encode(onSale, forKey: .onSale)
        try container.encode(purchasable, forKey: .purchasable)
        try container.encode(totalSales, forKey: .totalSales)
        try container.encode(virtual, forKey: .virtual)
        try container.encode(downloadable, forKey: .downloadable)
        try container.encodeIfPresent(externalUrl, forKey: .externalUrl)
        try container.encodeIfPresent(buttonText, forKey: .buttonText)
        try container.encode(taxStatus, forKey: .taxStatus)
        try container.encodeIfPresent(taxClass, forKey: .taxClass)
        try container.encode(manageStock, forKey: .manageStock)
        try container.encodeIfPresent(stockQuantity, forKey: .stockQuantity)
        try container.encode(stockStatus, forKey: .stockStatus)
        try container.encode(backorders, forKey: .backorders)
        try container.encode(backordersAllowed, forKey: .backordersAllowed)
        try container.encode(backordered, forKey: .backordered)
        try container.encodeIfPresent(lowStockAmount, forKey: .lowStockAmount)
        try container.encode(soldIndividually, forKey: .soldIndividually)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encode(dimensions, forKey: .dimensions)
        try container.encode(shippingRequired, forKey: .shippingRequired)
        try container.encode(shippingTaxable, forKey: .shippingTaxable)
        try container.encodeIfPresent(shippingClass, forKey: .shippingClass)
        try container.encode(shippingClassId, forKey: .shippingClassId)
        try container.encode(reviewsAllowed, forKey: .reviewsAllowed)
        try container.encode(averageRating, forKey: .averageRating)
        try container.encode(ratingCount, forKey: .ratingCount)
        try container.encode(relatedIds, forKey: .relatedIds) // Enkodiere immer, auch wenn leer
        try container.encode(upsellIds, forKey: .upsellIds)
        try container.encode(crossSellIds, forKey: .crossSellIds)
        try container.encode(parentId, forKey: .parentId)
        try container.encodeIfPresent(purchaseNote, forKey: .purchaseNote)
        try container.encode(categories, forKey: .categories)
        try container.encode(tags, forKey: .tags)
        try container.encode(images, forKey: .images)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(defaultAttributes, forKey: .defaultAttributes)
        try container.encode(variations, forKey: .variations)
        try container.encodeIfPresent(groupedProducts, forKey: .groupedProducts)
        try container.encode(menuOrder, forKey: .menuOrder)
        try container.encode(metaData, forKey: .metaData)
    }

    // Manueller Memberwise Initializer, da Codable-Implementierung den automatischen entfernt.
    // Dieser wird benötigt, wenn du WooCommerceProduct-Instanzen direkt im Code erstellen möchtest.
    // Für das reine Dekodieren von der API ist er nicht zwingend, aber gute Praxis.
    init(id: Int, name: String, slug: String, permalink: String, dateCreated: String, dateCreatedGmt: String,
         dateModified: String, dateModifiedGmt: String, type: ProductType, status: String, featured: Bool,
         catalogVisibility: String, description: String, shortDescription: String, sku: String,
         price: String, regularPrice: String, salePrice: String?, priceHtml: String?,
         dateOnSaleFrom: String?, dateOnSaleFromGmt: String?, dateOnSaleTo: String?, dateOnSaleToGmt: String?,
         onSale: Bool, purchasable: Bool, totalSales: Int, virtual: Bool, downloadable: Bool,
         externalUrl: String?, buttonText: String?, taxStatus: String, taxClass: String?,
         manageStock: Bool, stockQuantity: Int?, stockStatus: StockStatus, backorders: String,
         backordersAllowed: Bool, backordered: Bool, lowStockAmount: Int?, soldIndividually: Bool,
         weight: String?, dimensions: WooCommerceProductDimension, shippingRequired: Bool,
         shippingTaxable: Bool, shippingClass: String?, shippingClassId: Int, reviewsAllowed: Bool,
         averageRating: String, ratingCount: Int, relatedIds: [Int], upsellIds: [Int], crossSellIds: [Int],
         parentId: Int, purchaseNote: String?, categories: [WooCommerceCategoryRef],
         tags: [WooCommerceTagRef], images: [WooCommerceImage], attributes: [WooCommerceAttribute],
         defaultAttributes: [WooCommerceDefaultAttribute], variations: [Int], groupedProducts: [Int]?,
         menuOrder: Int, metaData: [WooCommerceMetaData]) {
        self.id = id; self.name = name; self.slug = slug; self.permalink = permalink; self.dateCreated = dateCreated; self.dateCreatedGmt = dateCreatedGmt;
        self.dateModified = dateModified; self.dateModifiedGmt = dateModifiedGmt; self.type = type; self.status = status; self.featured = featured;
        self.catalogVisibility = catalogVisibility; self.description = description; self.shortDescription = shortDescription; self.sku = sku;
        self.price = price; self.regularPrice = regularPrice; self.salePrice = salePrice; self.priceHtml = priceHtml;
        self.dateOnSaleFrom = dateOnSaleFrom; self.dateOnSaleFromGmt = dateOnSaleFromGmt; self.dateOnSaleTo = dateOnSaleTo; self.dateOnSaleToGmt = dateOnSaleToGmt;
        self.onSale = onSale; self.purchasable = purchasable; self.totalSales = totalSales; self.virtual = virtual; self.downloadable = downloadable;
        self.externalUrl = externalUrl; self.buttonText = buttonText; self.taxStatus = taxStatus; self.taxClass = taxClass;
        self.manageStock = manageStock; self.stockQuantity = stockQuantity; self.stockStatus = stockStatus; self.backorders = backorders;
        self.backordersAllowed = backordersAllowed; self.backordered = backordered; self.lowStockAmount = lowStockAmount; self.soldIndividually = soldIndividually;
        self.weight = weight; self.dimensions = dimensions; self.shippingRequired = shippingRequired;
        self.shippingTaxable = shippingTaxable; self.shippingClass = shippingClass; self.shippingClassId = shippingClassId; self.reviewsAllowed = reviewsAllowed;
        self.averageRating = averageRating; self.ratingCount = ratingCount; self.relatedIds = relatedIds; self.upsellIds = upsellIds; self.crossSellIds = crossSellIds;
        self.parentId = parentId; self.purchaseNote = purchaseNote; self.categories = categories;
        self.tags = tags; self.images = images; self.attributes = attributes;
        self.defaultAttributes = defaultAttributes; self.variations = variations; self.groupedProducts = groupedProducts;
        self.menuOrder = menuOrder; self.metaData = metaData;
    }
}
