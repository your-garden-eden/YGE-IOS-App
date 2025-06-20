// DATEI: ProductDetailViewModel.swift
// PFAD: Features/Products/ViewModels/Detail/ProductDetailViewModel.swift
// VERSION: FINAL - Alle Operationen integriert.

import Foundation

@MainActor
class ProductDetailViewModel: ObservableObject {
    
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var priceRangeDisplay: String?
    @Published var isLoadingVariations = false
    @Published var variationError: String?

    @Published var crossSellProducts: [WooCommerceProduct] = []
    @Published var isLoadingCrossSells = false

    private let api = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared

    func loadData(for product: WooCommerceProduct) async {
        logger.info("Lade Detaildaten für Produkt '\(product.name)' (ID: \(product.id)).")
        async let loadVariationsTask: () = loadVariations(for: product)
        async let loadCrossSellsTask: () = loadCrossSells(for: product)
        
        _ = await [loadVariationsTask, loadCrossSellsTask]
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
    
    private func loadCrossSells(for product: WooCommerceProduct) async {
        guard !product.safeCrossSellIDs.isEmpty else {
            logger.debug("Produkt \(product.id) hat keine Cross-Sells, überspringe Ladevorgang.")
            return
        }
        
        self.isLoadingCrossSells = true
        logger.info("Lade \(product.safeCrossSellIDs.count) Cross-Sell-Produkte für Produkt \(product.id)...")
        do {
            var params = ProductFilterParameters()
            params.include = product.safeCrossSellIDs
            
            let response = try await api.fetchProducts(params: params)
            self.crossSellProducts = response.products
            logger.info("\(response.products.count) Cross-Sell-Produkte erfolgreich geladen.")
            
        } catch {
            logger.warning("Fehler beim Laden der Cross-Sell-Produkte für Produkt \(product.id): \(error.localizedDescription). Dies wird ignoriert, um die UI nicht zu blockieren.")
            self.crossSellProducts = []
        }
        self.isLoadingCrossSells = false
    }
}
