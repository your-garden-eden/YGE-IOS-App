// Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductDetailViewModel.swift

import Foundation
import Combine

class ProductDetailViewModel: ObservableObject {
    @Published var product: WooCommerceProduct?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedQuantity: Int = 1

    let productId: Int
    private let wooAPIManager = WooCommerceAPIManager.shared

    init(productId: Int, initialProductData: WooCommerceProduct? = nil) {
        self.productId = productId
        print("ProductDetailViewModel initialized for productId: \(productId)")

        if let initialData = initialProductData {
            self.product = initialData
            // Annahme: initialData.name ist nicht optional
            print("Initial product data provided for \(initialData.name)")
        } else {
            loadProductDetails()
        }
    }

    func loadProductDetails() {
        print("ProductDetailViewModel: loadProductDetails called for productId: \(productId)")
        self.isLoading = true
        self.errorMessage = nil
        self.selectedQuantity = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false

            // Stelle sicher, dass WooCommerceImage einen passenden init hat
            let placeholderImage1 = WooCommerceImage(id: 2001, src: "https://via.placeholder.com/600x400/00AA00/FFFFFF?Text=Detail+1+ID+\(strongSelf.productId)", name: "Detailbild 1", alt: "Detailbild 1")
            let placeholderImage2 = WooCommerceImage(id: 2002, src: "https://via.placeholder.com/600x400/00BB00/FFFFFF?Text=Detail+2+ID+\(strongSelf.productId)", name: "Detailbild 2", alt: "Detailbild 2")
            
            // Aufruf passt zur WooCommerceAttribute-Definition OHNE Datumsfelder
            let attributeColor = WooCommerceAttribute( // ZEILE ~37
                id: 1,
                name: "Farbe",
                slug: "pa_farbe",
                position: 0,
                visible: true,
                variation: true,
                options: ["Rot", "Grün", "Blau"]
            )
            let attributeSize = WooCommerceAttribute(
                id: 2,
                name: "Größe",
                slug: "pa_groesse",
                position: 1,
                visible: true,
                variation: true,
                options: ["S", "M", "L"]
            )

            // Erstellung des simulierten Produkts
            // Placeholder für komplexe Typen entfernt oder minimal initialisiert
            let simulatedProduct = WooCommerceProduct(
                id: strongSelf.productId,
                name: "Detailliertes Sim-Produkt \(strongSelf.productId)",
                slug: "detail-sim-produkt-\(strongSelf.productId)",
                permalink: "http://example.com/product/detail-sim-produkt-\(strongSelf.productId)",
                dateCreated: "2023-01-15T10:00:00",
                dateCreatedGmt: "2023-01-15T10:00:00Z",
                dateModified: "2023-01-16T11:00:00",
                dateModifiedGmt: "2023-01-16T11:00:00Z",
                type: "variable",
                status: "publish",
                featured: false,
                catalogVisibility: "visible",
                description: "Dies ist eine <strong>längere und detailliertere</strong> HTML-Beschreibung...",
                shortDescription: "Fantastisches Detail-Produkt...",
                sku: "DET-SIM-\(strongSelf.productId)",
                price: "29.99",
                regularPrice: "35.00",
                salePrice: "29.99",
                priceHtml: "<del>35.00€</del> <ins>29.99€</ins>",
                dateOnSaleFrom: nil,
                dateOnSaleFromGmt: nil,
                dateOnSaleTo: nil,
                dateOnSaleToGmt: nil,
                onSale: true,
                purchasable: true,
                totalSales: 120,
                virtual: false,
                downloadable: false,
                downloads: [], // Leeres Array (wenn WooCommerceProductDownload optional ist, sonst initialisieren)
                downloadLimit: nil,
                downloadExpiry: nil,
                externalUrl: nil,
                buttonText: nil,
                taxStatus: "taxable",
                taxClass: nil,
                manageStock: true,
                stockQuantity: 15,
                stockStatus: "instock",
                backorders: "no",
                backordersAllowed: false,
                backordered: false,
                lowStockAmount: nil,
                soldIndividually: false,
                weight: "0.5 kg",
                // dimensions ist NICHT optional in deinem WooCommerceProduct-Modell
                // Stelle sicher, dass WooCommerceProductDimension einen passenden init hat
                dimensions: WooCommerceProductDimension(length: "10", width: "5", height: "2"),
                shippingRequired: true,
                shippingTaxable: true,
                shippingClass: nil,
                shippingClassId: 0,
                reviewsAllowed: true,
                averageRating: "4.5",
                ratingCount: 75,
                relatedIds: [],
                upsellIds: [],
                crossSellIds: [],
                parentId: 0,
                purchaseNote: "Vielen Dank für Ihren Einkauf!",
                // categories ist NICHT optional
                // Stelle sicher, dass WooCommerceCategoryRef einen passenden init hat
                categories: [WooCommerceCategoryRef(id: 1, name: "Simulierte Kategorie", slug: "sim-kat")],
                tags: [],
                // images ist NICHT optional
                images: [placeholderImage1, placeholderImage2],
                // attributes ist NICHT optional
                attributes: [attributeColor, attributeSize],
                // defaultAttributes ist NICHT optional
                // Stelle sicher, dass WooCommerceDefaultAttribute einen passenden init hat
                defaultAttributes: [], // Oder z.B. [WooCommerceDefaultAttribute(id: 0, name: "Farbe", option: "Rot")]
                variations: [],
                groupedProducts: nil,
                menuOrder: 0,
                // metaData ist NICHT optional
                // Stelle sicher, dass WooCommerceMetaData einen passenden init hat
                metaData: [] // Oder z.B. [WooCommerceMetaData(id:1, key: "_test", value: "testWert")]
            )
            strongSelf.product = simulatedProduct
        })
    }

    func addToCart() {
        guard let product = product else {
            errorMessage = "Kein Produkt zum Hinzufügen ausgewählt."
            return
        }
        // Annahme: product.name ist nicht optional
        print("ProductDetailViewModel: Produkt '\(product.name)' (ID: \(self.productId)) mit Menge \(selectedQuantity) zum Warenkorb hinzugefügt (SIMULIERT).")
    }
}
