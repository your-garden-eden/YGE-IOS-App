// Dateiname: ProductDetailViewModel.swift

import SwiftUI

@MainActor
class ProductDetailViewModel: ObservableObject {
    let product: WooCommerceProduct
    
    @Published var productName: String
    @Published var productDescription: String
    @Published var initialDisplayPrice: String
    
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
        self.productName = product.name
        self.productDescription = ""
        self.initialDisplayPrice = ""
    }
    
    func prepareDisplayData() async {
        let cleanedName = product.name.strippingHTML()
        let cleanedDescription = product.description.strippingHTML()
        let formattedPrice = PriceFormatter.formatPriceString(
            from: product.priceHtml,
            fallbackPrice: product.price,
            currencySymbol: "€"
        )
        self.productName = cleanedName
        self.productDescription = cleanedDescription
        self.initialDisplayPrice = formattedPrice.display
    }
    
    func loadVariationsIfNeeded() async {
        guard self.effectiveProductType == "variable", variations.isEmpty, !isLoading else { return }
        
        self.isLoading = true
        self.loadingError = nil
        
        do {
            let fetchedVariations = try await WooCommerceAPIManager.shared.fetchProductVariations(productId: product.id)
            self.variations = fetchedVariations
        } catch {
            let errorMessage = "Die Produktoptionen konnten nicht geladen werden."
            self.loadingError = errorMessage
            print("🔴 ProductDetailViewModel: Failed to load variations - \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
    
    func addSimpleProductToCart() async {
        guard self.effectiveProductType == "simple", !isAddingToCart else { return }
        
        isAddingToCart = true
        
        // KORREKTUR: Kein do-try-catch mehr nötig. Wir rufen die sichere Funktion direkt auf.
        await CartAPIManager.shared.addItem(productId: product.id, quantity: self.quantity)
        
        isAddingToCart = false
    }
}
