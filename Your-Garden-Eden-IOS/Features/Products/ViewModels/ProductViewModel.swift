// Dateiname: ProductViewModel.swift

import Foundation

@MainActor
class ProductViewModel: ObservableObject {
    
    // --- ZUSTAND ---
    @Published var bestsellerProducts: [WooCommerceProduct] = []
    @Published var isLoadingBestsellers: Bool = false
    @Published var bestsellerErrorMessage: String?
    
    // --- DEPENDENCIES ---
    private let wooAPIManager = WooCommerceAPIManager.shared

    // --- INITIALISIERER ---
    // Lädt Bestseller automatisch, sobald die App startet.
    init() {
        print("✅ ProductViewModel: Initialized. Automatically fetching bestsellers.")
        self.isLoadingBestsellers = true
        
        Task {
            await loadBestsellerProducts()
        }
    }
    
    // --- PRIVATE LADEFUNKTION ---
    private func loadBestsellerProducts() async {
        bestsellerErrorMessage = nil
        
        do {
            let container = try await wooAPIManager.fetchProducts(perPage: 20, orderBy: "popularity")
            self.bestsellerProducts = container.products
            print("👍 ProductViewModel: Successfully loaded \(bestsellerProducts.count) bestseller products.")
        } catch {
            let errorMessage = "Die Bestseller konnten nicht geladen werden."
            self.bestsellerErrorMessage = errorMessage
            print("❌ FEHLER (Bestseller): \(error.localizedDescription)")
        }
        
        self.isLoadingBestsellers = false
    }
}
