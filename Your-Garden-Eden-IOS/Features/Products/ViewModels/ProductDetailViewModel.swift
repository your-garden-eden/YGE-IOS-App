// DATEI: ProductDetailViewModel.swift
// PFAD: Features/Products/ViewModels/ProductDetailViewModel.swift
// VERSION: 1.0 (FINAL)

import Foundation

@MainActor
class ProductDetailViewModel: ObservableObject {
    
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var recommendedProducts: [WooCommerceProduct] = []
    
    @Published var isLoadingVariations = false
    @Published var isLoadingRecommendations = false
    @Published var variationError: String?
    
    private let api = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared

    func loadData(for product: WooCommerceProduct) async {
        logger.info("Lade Detail-Daten für Produkt \(product.id).")
        async let _ = loadVariations(for: product)
        async let _ = loadRecommendedProducts(for: product)
    }
    
    private func loadVariations(for product: WooCommerceProduct) async {
        guard product.type == "variable" else { return }
        self.isLoadingVariations = true
        self.variationError = nil
        
        do {
            self.variations = try await api.fetchProductVariations(productId: product.id)
            if self.variations.isEmpty {
                self.variationError = "Für dieses Produkt sind derzeit keine Optionen verfügbar."
                logger.warning("Keine Variationen für variables Produkt \(product.id) gefunden.")
            }
        } catch {
            self.variationError = "Optionen konnten nicht geladen werden."
            logger.error("Fehler beim Laden der Variationen für Produkt \(product.id): \(error.localizedDescription)")
        }
        self.isLoadingVariations = false
    }
    
    private func loadRecommendedProducts(for product: WooCommerceProduct) async {
        let combinedIDs = Array(Set(product.safeCrossSellIDs + product.safeRelatedIDs))
        guard !combinedIDs.isEmpty else { return }
        
        self.isLoadingRecommendations = true
        defer { self.isLoadingRecommendations = false }
        
        var params = ProductFilterParameters(); params.include = combinedIDs
        
        do {
            let response = try await api.fetchProducts(params: params, perPage: combinedIDs.count)
            self.recommendedProducts = response.products
        } catch {
            logger.error("Fehler beim Laden der empfohlenen Produkte für Produkt \(product.id): \(error.localizedDescription)")
        }
    }
}
