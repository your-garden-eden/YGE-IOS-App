// DATEI: ProductDetailViewModel.swift
// PFAD: Features/Products/ViewModels/Detail/ProductDetailViewModel.swift
// ZWECK: Verwaltet den Zustand und die Geschäftslogik für die `ProductDetailView`,
//        einschließlich des Ladens von Variationen und Cross-Sell-Produkten.

import Foundation

@MainActor
class ProductDetailViewModel: ObservableObject {
    
    // MARK: - Veröffentlichte Eigenschaften für die View
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var priceRangeDisplay: String?
    @Published var isLoadingVariations = false
    @Published var variationError: String?

    @Published var crossSellProducts: [WooCommerceProduct] = []
    @Published var isLoadingCrossSells = false

    // MARK: - Private Eigenschaften
    private let api = WooCommerceAPIManager.shared

    // MARK: - Öffentliche Methoden
    
    /// Lädt alle für die Detailansicht notwendigen Daten parallel.
    /// - Parameter product: Das Produkt, für das die Daten geladen werden sollen.
    func loadData(for product: WooCommerceProduct) async {
        // Startet zwei asynchrone Aufgaben parallel: das Laden von Variationen und Cross-Sells.
        async let loadVariationsTask: () = loadVariations(for: product)
        async let loadCrossSellsTask: () = loadCrossSells(for: product)
        
        // Wartet, bis beide Aufgaben abgeschlossen sind, bevor die Funktion zurückkehrt.
        _ = await [loadVariationsTask, loadCrossSellsTask]
    }
    
    // MARK: - Private Lade-Methoden
    
    /// Lädt die Produktvariationen, falls es sich um ein variables Produkt handelt.
    private func loadVariations(for product: WooCommerceProduct) async {
        guard product.type == "variable" else { return }

        self.isLoadingVariations = true
        self.variationError = nil
        
        do {
            let fetchedVariations = try await api.fetchProductVariations(productId: product.id)
            self.variations = fetchedVariations
            
            // KORREKTUR: Anbindung an den zentralen PriceFormatter.
            self.priceRangeDisplay = PriceFormatter.calculatePriceRange(from: fetchedVariations)
            
        } catch let apiError as WooCommerceAPIError {
            self.variationError = apiError.localizedDescriptionForUser
        } catch {
            self.variationError = "Fehler beim Laden der Produktoptionen."
        }
        
        self.isLoadingVariations = false
    }
    
    /// Lädt die Cross-Sell-Produkte, falls welche im Produkt definiert sind.
    private func loadCrossSells(for product: WooCommerceProduct) async {
        guard !product.safeCrossSellIDs.isEmpty else { return }
        
        self.isLoadingCrossSells = true
        do {
            var params = ProductFilterParameters()
            params.include = product.safeCrossSellIDs
            
            let response = try await api.fetchProducts(params: params)
            self.crossSellProducts = response.products
            
        } catch {
            // Fehler werden im Hintergrund protokolliert, um die UI nicht zu stören.
            print("🔴 Fehler beim Laden der Cross-Sell-Produkte: \(error.localizedDescription)")
            self.crossSellProducts = []
        }
        self.isLoadingCrossSells = false
    }
}
