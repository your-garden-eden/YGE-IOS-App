// DATEI: ProductDetailViewModel.swift
// PFAD: Features/Products/ViewModels/Detail/ProductDetailViewModel.swift
// VERSION: OPERATION "DOPPEL-AGENT" - Phase 2 (VOLLSTÄNDIG)

import Foundation

@MainActor
class ProductDetailViewModel: ObservableObject {
    
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var priceRangeDisplay: String?
    @Published var isLoadingVariations = false
    @Published var variationError: String?

    // --- BEGINN MODIFIKATION ---
    @Published var recommendedProducts: [WooCommerceProduct] = []
    @Published var isLoadingRecommendations = false
    // --- ENDE MODIFIKATION ---

    private let api = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared

    func loadData(for product: WooCommerceProduct) async {
        logger.info("Lade Detaildaten für Produkt '\(product.name)' (ID: \(product.id)).")
        async let loadVariationsTask: () = loadVariations(for: product)
        // --- BEGINN MODIFIKATION ---
        async let loadRecommendedProductsTask: () = loadRecommendedProducts(for: product)
        _ = await [loadVariationsTask, loadRecommendedProductsTask]
        // --- ENDE MODIFIKATION ---
        logger.info("Laden der Detaildaten für Produkt \(product.id) abgeschlossen.")
    }
    
    private func loadVariations(for product: WooCommerceProduct) async {
        guard product.type == "variable" else {
            logger.debug("Produkt \(product.id) ist kein variables Produkt, überspringe Variationen-Ladevorgang.")
            return
        }

        self.isLoadingVariations = true
        self.variationError = nil
        logger.info("Lade Variationen für Produkt \(product.id)...")
        
        do {
            let fetchedVariations = try await api.fetchProductVariations(productId: product.id)
            self.variations = fetchedVariations
            self.priceRangeDisplay = PriceFormatter.calculatePriceRange(from: fetchedVariations)
            logger.info("\(fetchedVariations.count) Variationen für Produkt \(product.id) erfolgreich geladen.")
            
        } catch let apiError as WooCommerceAPIError {
            self.variationError = apiError.localizedDescriptionForUser
            logger.error("Fehler beim Laden der Variationen für Produkt \(product.id): \(apiError.localizedDescription)")
        } catch {
            self.variationError = "Fehler beim Laden der Produktoptionen."
            logger.error("Unerwarteter Fehler beim Laden der Variationen für Produkt \(product.id): \(error.localizedDescription)")
        }
        
        self.isLoadingVariations = false
    }
    
    // --- BEGINN MODIFIKATION ---
    private func loadRecommendedProducts(for product: WooCommerceProduct) async {
        // Sammle IDs aus beiden Quellen und entferne Duplikate.
        let combinedIDs = product.safeCrossSellIDs + product.safeRelatedIDs
        let uniqueIDs = Array(Set(combinedIDs))
        
        guard !uniqueIDs.isEmpty else {
            logger.debug("Produkt \(product.id) hat keine verknüpften Produkte (Cross-Sell/Related), überspringe Ladevorgang.")
            return
        }
        
        self.isLoadingRecommendations = true
        logger.info("Lade \(uniqueIDs.count) empfohlene Produkte für Produkt \(product.id)...")
        do {
            var params = ProductFilterParameters()
            params.include = uniqueIDs
            
            let response = try await api.fetchProducts(params: params)
            self.recommendedProducts = response.products
            logger.info("\(response.products.count) empfohlene Produkte erfolgreich geladen.")
            
        } catch {
            logger.warning("Fehler beim Laden der empfohlenen Produkte für Produkt \(product.id): \(error.localizedDescription). Dies wird ignoriert, um die UI nicht zu blockieren.")
            self.recommendedProducts = []
        }
        self.isLoadingRecommendations = false
    }
    // --- ENDE MODIFIKATION ---
}
