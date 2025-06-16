// Path: Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductDetailViewModel.swift
// VERSION 1.0 (FINAL)

import Foundation

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var priceRangeDisplay: String?
    @Published var isLoadingVariations = false
    @Published var variationError: String?

    // Platzhalter für Cross-Sell-Logik, falls benötigt
    @Published var crossSellProducts: [WooCommerceProduct] = []
    @Published var isLoadingCrossSells = false

    private let api = WooCommerceAPIManager.shared

    func loadData(for product: WooCommerceProduct) async {
        // Zwei Aufgaben parallel ausführen: Variationen und Cross-Sells laden
        async let loadVariationsTask: () = loadVariations(for: product)
        async let loadCrossSellsTask: () = loadCrossSells(for: product)
        
        _ = await [loadVariationsTask, loadCrossSellsTask]
    }
    
    private func loadVariations(for product: WooCommerceProduct) async {
        guard product.type == "variable" else { return }

        self.isLoadingVariations = true
        self.variationError = nil
        
        do {
            let fetchedVariations = try await api.fetchProductVariations(productId: product.id)
            self.variations = fetchedVariations
            self.priceRangeDisplay = PriceFormatter.calculatePriceRange(from: fetchedVariations)
            
        } catch let apiError as WooCommerceAPIError {
            self.variationError = apiError.localizedDescriptionForUser
        } catch {
            self.variationError = "Fehler beim Laden der Produktoptionen."
        }
        
        self.isLoadingVariations = false
    }
    
    private func loadCrossSells(for product: WooCommerceProduct) async {
        guard !product.safeCrossSellIDs.isEmpty else { return }
        
        self.isLoadingCrossSells = true
        do {
            let response = try await api.fetchProducts(include: product.safeCrossSellIDs)
            self.crossSellProducts = response.products
        } catch {
            print("🔴 Fehler beim Laden der Cross-Sell-Produkte: \(error.localizedDescription)")
            self.crossSellProducts = []
        }
        self.isLoadingCrossSells = false
    }
}
