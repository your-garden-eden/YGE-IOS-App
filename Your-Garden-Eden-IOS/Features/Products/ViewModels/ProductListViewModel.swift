// Dateiname: Features/Products/ViewModels/ProductListViewModel.swift

import Foundation
import Combine

@MainActor
class ProductListViewModel: ObservableObject {
    
    // Zustand der View
    @Published private(set) var products: [WooCommerceProduct] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var canLoadMore = true
    
    // Konfiguration
    private let categoryId: Int
    private let apiManager = WooCommerceAPIManager.shared
    private var currentPage = 1
    
    init(categoryId: Int) {
        self.categoryId = categoryId
        print("📦 ProductListViewModel initialized for category ID: \(categoryId)")
    }
    
    func loadProducts(initialLoad: Bool = false) async {
        // Verhindere doppelte Ladevorgänge
        guard !isLoading else { return }
        
        // Wenn es eine initiale Ladung ist, setze alles zurück
        if initialLoad {
            currentPage = 1
            products = []
            canLoadMore = true
            errorMessage = nil
        }
        
        // Wenn wir nicht mehr laden können, breche ab
        guard canLoadMore else { return }
        
        isLoading = true
        
        do {
            let response = try await apiManager.fetchProducts(
                categoryId: self.categoryId,
                page: self.currentPage
            )
            
            // Füge die neuen Produkte hinzu
            self.products.append(contentsOf: response.products)
            
            // Prüfe, ob wir das Ende der Paginierung erreicht haben
            self.canLoadMore = response.totalPages > self.currentPage
            
            // Bereite die nächste Seite vor
            self.currentPage += 1
            
        } catch {
            self.errorMessage = "Produkte konnten nicht geladen werden."
            print("🔴 ProductListViewModel Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // Hilfsfunktion für die unendliche Scroll-Logik
    func isLastProduct(_ product: WooCommerceProduct) -> Bool {
        return products.last?.id == product.id
    }
}
