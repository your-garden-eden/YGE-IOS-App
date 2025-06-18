// Path: Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductViewModel.swift
// VERSION 3.0 (INFRASTRUCTURE CONNECTED)

import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Hält die Liste der Bestseller-Produkte für die Anzeige auf der HomeView.
    @Published var bestsellerProducts: [WooCommerceProduct] = []
    
    /// Steuert den Lade-Indikator für die Bestseller-Sektion.
    @Published var isLoadingBestsellers: Bool = false
    
    /// Hält eine Fehlermeldung, falls das Laden der Bestseller fehlschlägt.
    @Published var bestsellerErrorMessage: String?
    
    // MARK: - Private Properties
    
    private let wooAPIManager = WooCommerceAPIManager.shared

    // MARK: - Initializer
    
    init() {
        print("✅ ProductViewModel initialized (lazy).")
    }
    
    // MARK: - Public Methods
    
    /// Lädt die Bestseller-Produkte vom Server, dedupliziert sie und reichert sie mit Preisspannen an.
    func fetchBestsellers() async {
        guard !isLoadingBestsellers else { return }
        
        self.isLoadingBestsellers = true
        self.bestsellerErrorMessage = nil
        print("▶️ ProductViewModel: Fetching bestsellers...")
        
        do {
            // ===================================================================
            // **KORREKTUR: Der API-Aufruf wurde an die neue, saubere Methode angepasst.**
            // Wir erstellen ein `ProductFilterParameters`-Objekt und übergeben es.
            // ===================================================================
            var params = ProductFilterParameters()
            params.orderBy = "popularity"
            
            let container = try await wooAPIManager.fetchProducts(params: params, perPage: 20)
            
            // --- DATEN-REINIGUNG (DEDUPLIZIERUNG) ---
            var seenIDs = Set<Int>()
            var uniqueProducts = container.products.filter { product in
                seenIDs.insert(product.id).inserted
            }
            
            // --- PREISSPANNEN-ANREICHERUNG ---
            try await withThrowingTaskGroup(of: (Int, String?).self) { group in
                for product in uniqueProducts where product.type == "variable" {
                    group.addTask {
                        _ = try await self.wooAPIManager.fetchProductVariations(productId: product.id)
                        // Ersetzen Sie dies durch Ihren echten PriceFormatter
                        // let range = PriceFormatter.calculatePriceRange(from: variations)
                        let range = "Preisspanne" // Platzhalter
                        return (product.id, range)
                    }
                }
                
                for try await (productId, range) in group {
                    if let range = range, let index = uniqueProducts.firstIndex(where: { $0.id == productId }) {
                        uniqueProducts[index].priceRangeDisplay = range
                    }
                }
            }
            
            // --- FINALE DATEN VERÖFFENTLICHEN ---
            self.bestsellerProducts = uniqueProducts
            print("👍 ProductViewModel: Successfully loaded and cleaned \(bestsellerProducts.count) bestseller products.")
            
        } catch let error as WooCommerceAPIError {
            self.bestsellerErrorMessage = "Die Bestseller konnten nicht geladen werden."
            print("❌ FEHLER (Bestseller): \(error.localizedDescriptionForUser)")
        } catch {
            self.bestsellerErrorMessage = "Die Bestseller konnten nicht geladen werden."
            print("❌ FEHLER (Bestseller): \(error.localizedDescription)")
        }
        
        self.isLoadingBestsellers = false
    }
}
