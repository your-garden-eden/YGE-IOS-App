//
//  ProductDetailViewModel.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import SwiftUI

@MainActor
class ProductDetailViewModel: ObservableObject {
    let product: WooCommerceProduct
    
    // --- START ÄNDERUNG 1.4.1 ---
    // Die Eigenschaften werden zu @Published Var, damit sie nach der asynchronen
    // Vorbereitung aktualisiert werden können und die UI darauf reagiert.
    @Published var productName: String
    @Published var productDescription: String
    @Published var initialDisplayPrice: String
    // --- ENDE ÄNDERUNG 1.4.1 ---
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadingError: String?
    @Published private(set) var variations: [WooCommerceProductVariation] = []
    @Published var quantity: Int = 1
    @Published private(set) var isAddingToCart: Bool = false

    var effectiveProductType: String {
        if product.type == .variable { return "variable" }
        if !product.variations.isEmpty { return "variable" }
        if product.attributes.contains(where: { $0.variation }) { return "variable" }
        return "simple"
    }

    init(product: WooCommerceProduct) {
        self.product = product
        
        // --- START ÄNDERUNG 1.4.2 ---
        // Der Initializer wird extrem schnell und sicher gemacht.
        // Er verwendet die Roh-Daten oder Platzhalter. KEINE HTML-Verarbeitung hier!
        self.productName = product.name // Temporär der rohe Name
        self.productDescription = "" // Leerer Platzhalter
        self.initialDisplayPrice = "" // Leerer Platzhalter
        // --- ENDE ÄNDERUNG 1.4.2 ---
    }
    
    // --- START ÄNDERUNG 1.4.3 ---
    // NEUE, ASYNCHRONE FUNKTION:
    // Diese Funktion übernimmt die rechenintensive Arbeit. Sie wird von der View
    // in einem .task-Block aufgerufen, also sicher und asynchron.
    func prepareDisplayData() async {
        // Bereite die sauberen Strings vor.
        // Diese Operation läuft jetzt sicher, nachdem die View initialisiert wurde.
        let cleanedName = product.name.strippingHTML()
        let cleanedDescription = product.description.strippingHTML()
        let formattedPrice = PriceFormatter.formatPriceString(
            from: product.priceHtml,
            fallbackPrice: product.price,
            currencySymbol: "€"
        )
        
        // Aktualisiere die @Published-Eigenschaften.
        // Da die Funktion @MainActor ist, ist dieser Zugriff threadsicher.
        self.productName = cleanedName
        self.productDescription = cleanedDescription
        self.initialDisplayPrice = formattedPrice.display
    }
    // --- ENDE ÄNDERUNG 1.4.3 ---
    
    func loadVariationsIfNeeded() async {
        guard self.effectiveProductType == "variable", variations.isEmpty, !isLoading else {
            return
        }
        
        self.isLoading = true
        self.loadingError = nil
        
        do {
            let fetchedVariations = try await WooCommerceAPIManager.shared.fetchProductVariations(productId: product.id)
            self.variations = fetchedVariations
        } catch {
            let errorMessage = "Die Produktoptionen konnten nicht geladen werden."
            self.loadingError = errorMessage
        }
        
        self.isLoading = false
    }
    
    func addSimpleProductToCart() async -> Bool {
        guard self.effectiveProductType == "simple", !isAddingToCart else { return false }
        
        isAddingToCart = true
        defer { isAddingToCart = false }
        
        do {
            try await CartAPIManager.shared.addItem(productId: product.id, quantity: self.quantity)
            return true
        } catch {
            return false
        }
    }
}
