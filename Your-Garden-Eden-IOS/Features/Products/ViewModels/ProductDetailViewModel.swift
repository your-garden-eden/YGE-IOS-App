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
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadingError: String?
    @Published private(set) var variations: [WooCommerceProductVariation] = []
    @Published var quantity: Int = 1
    @Published private(set) var isAddingToCart: Bool = false

    let initialDisplayPrice: String

    /// Gibt den effektiven Produkttyp als String zurück.
    /// Ein Produkt gilt als "variable", wenn es so getaggt ist, oder wenn es als "simple" getaggt ist, aber Variations-IDs hat.
    var effectiveProductType: String {
        if product.type.rawValue == "variable" {
            return "variable"
        }
        if product.type.rawValue == "simple" && !product.variations.isEmpty {
            return "variable"
        }
        return "simple"
    }

    init(product: WooCommerceProduct) {
        self.product = product
        self.initialDisplayPrice = (product.priceHtml ?? product.price).strippingHTML()
    }
    
    func loadVariationsIfNeeded() async {
        // KORREKTUR: Verwendet den String-Vergleich.
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
        // KORREKTUR: Verwendet den String-Vergleich.
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
