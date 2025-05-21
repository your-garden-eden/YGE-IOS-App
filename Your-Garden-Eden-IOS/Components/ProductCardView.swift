// In Models/WooCommerce/WooCommerceProduct.swift

// ... (dein bestehender WooCommerceProduct Struct Code) ...

extension WooCommerceProduct { // Oder direkt im Struct, wenn du das bevorzugst
var placeholder: WooCommerceProduct {
        // ... (die vollständige Definition des Placeholder-Produkts, wie in meiner vorherigen Antwort) ...
        // Beispielhaft gekürzt:
        let mockImage = WooCommerceImage.placeholder // Annahme: WooCommerceImage hat auch .placeholder
        let mockDimension = WooCommerceProductDimension.placeholder // Annahme
        let mockCategoryRef = WooCommerceCategoryRef.placeholder // Annahme

        return WooCommerceProduct(
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
            soldIndividually: false, weight: "1kg", dimensions: mockDimension,
            shippingRequired: true, shippingTaxable: true, shippingClass: "", shippingClassId: 0,
            reviewsAllowed: true, averageRating: "0", ratingCount: 0,
            relatedIds: [], upsellIds: [], crossSellIds: [], parentId: 0, purchaseNote: "",
            categories: [mockCategoryRef],
            tags: [], // Benötigt WooCommerceTagRef.placeholder, wenn nicht leer
            images: [mockImage],
            attributes: [], // Benötigt WooCommerceAttribute.placeholder, wenn nicht leer
            defaultAttributes: [], // Benötigt WooCommerceDefaultAttribute.placeholder, wenn nicht leer
            variations: [], groupedProducts: [], menuOrder: 0,
            metaData: [] // Benötigt WooCommerceMetaData.placeholder, wenn nicht leer
        )
    }
}
