// Features/Products/ViewModels/ProductDetailViewModel.swift

import SwiftUI

@MainActor
class ProductDetailViewModel: ObservableObject {
    // MARK: - Input Property
    let product: WooCommerceProduct
    
    // MARK: - Published State
    @Published private(set) var isLoadingVariations: Bool = false
    @Published private(set) var loadingError: String?
    
    // NEU: Hält den spezialisierten ViewModel, sobald die Variationen geladen sind.
    @Published private(set) var optionsViewModel: ProductOptionsViewModel?
    
    // NEU: Hält den initialen Preis, bevor eine Variante gewählt wird.
    let initialDisplayPrice: String

    // MARK: - Initializer
    init(product: WooCommerceProduct) {
        self.product = product
        self.initialDisplayPrice = (product.priceHtml ?? product.price).strippingHTML()
    }
    
    // MARK: - Data Loading
    
    func loadVariationsIfNeeded() async {
        // Nur für variable Produkte laden und nur einmal.
        guard product.type == .variable, optionsViewModel == nil, !isLoadingVariations else {
            // Für einfache Produkte erstellen wir sofort einen "Dummy" ViewModel
            if product.type == .simple && optionsViewModel == nil {
                self.optionsViewModel = ProductOptionsViewModel(product: product, variations: [])
            }
            return
        }
        
        self.isLoadingVariations = true
        self.loadingError = nil
        
        do {
            let fetchedVariations = try await WooCommerceAPIManager.shared.fetchProductVariations(productId: product.id)
            
            // Erstelle und speichere den neuen, spezialisierten ViewModel.
            self.optionsViewModel = ProductOptionsViewModel(product: product, variations: fetchedVariations)
            
        } catch {
            let errorMessage = "Die Produktoptionen konnten nicht geladen werden."
            print("🔴 Failed to load variations: \(error)")
            self.loadingError = errorMessage
        }
        
        self.isLoadingVariations = false
    }
}
