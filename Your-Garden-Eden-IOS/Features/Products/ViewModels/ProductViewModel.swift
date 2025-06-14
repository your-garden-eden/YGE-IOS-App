// Dateiname: ViewModels/ProductViewModel.swift

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
        guard !isLoadingBestsellers else { return }
        self.isLoadingBestsellers = true
        self.bestsellerErrorMessage = nil
        print("▶️ ProductViewModel: Fetching bestsellers...")
        do {
            let container = try await wooAPIManager.fetchProducts(perPage: 20, orderBy: "popularity")
            self.bestsellerProducts = container.products
            print("👍 ProductViewModel: Successfully loaded \(bestsellerProducts.count) bestseller products.")
        } catch {
            self.bestsellerErrorMessage = "Die Bestseller konnten nicht geladen werden."
            print("❌ FEHLER (Bestseller): \(error.localizedDescription)")
        }
        self.isLoadingBestsellers = false
    }
}
