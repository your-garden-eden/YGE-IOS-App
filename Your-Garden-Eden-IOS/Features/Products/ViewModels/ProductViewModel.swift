// Path: Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductViewModel.swift
// VERSION 2.0 (FINAL - Deduplication & Price Enrichment)

import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    @Published var bestsellerProducts: [WooCommerceProduct] = []
    @Published var isLoadingBestsellers: Bool = false
    @Published var bestsellerErrorMessage: String?
    private let wooAPIManager = WooCommerceAPIManager.shared

    init() {
        print("✅ ProductViewModel initialized (lazy).")
    }
    
    func fetchBestsellers() async {
        // Schutzklausel, um doppelte Ladevorgänge zu verhindern.
        guard !isLoadingBestsellers else { return }
        
        self.isLoadingBestsellers = true
        self.bestsellerErrorMessage = nil
        print("▶️ ProductViewModel: Fetching bestsellers...")
        
        do {
            // --- SCHRITT 1: BASIS-PRODUKTE LADEN (wie bisher) ---
            let container = try await wooAPIManager.fetchProducts(perPage: 20, orderBy: "popularity")
            
            // ===================================================================
            // **HIER IST DIE NEUE, KUGELSICHERE LOGIK**
            // ===================================================================
            
            // --- SCHRITT 2: DATEN-REINIGUNG (DEDUPLIZIERUNG) ---
            var seenIDs = Set<Int>()
            // Filtere die von der API erhaltene Liste. Behalte nur Produkte, deren ID zum ersten Mal gesehen wird.
            var uniqueProducts = container.products.filter { product in
                seenIDs.insert(product.id).inserted
            }
            
            // --- SCHRITT 3: PREISSPANNEN-ANREICHERUNG ---
            // Wir verwenden eine TaskGroup für maximale Performance, um die Preisspannen parallel zu laden.
            try await withThrowingTaskGroup(of: (Int, String?).self) { group in
                for product in uniqueProducts where product.type == "variable" {
                    group.addTask {
                        let variations = try await self.wooAPIManager.fetchProductVariations(productId: product.id)
                        let range = PriceFormatter.calculatePriceRange(from: variations)
                        return (product.id, range)
                    }
                }
                
                // Sammle die Ergebnisse und aktualisiere die 'uniqueProducts'-Liste.
                for try await (productId, range) in group {
                    if let range = range, let index = uniqueProducts.firstIndex(where: { $0.id == productId }) {
                        uniqueProducts[index].priceRangeDisplay = range
                    }
                }
            }
            
            // --- SCHRITT 4: FINALE, SAUBERE DATEN VERÖFFENTLICHEN ---
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
