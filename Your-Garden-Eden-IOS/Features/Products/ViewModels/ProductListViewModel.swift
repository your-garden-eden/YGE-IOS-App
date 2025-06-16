// Path: Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductListViewModel.swift
// VERSION 2.0 (FINAL - With Price Range Enrichment)

import Foundation

@MainActor
class ProductListViewModel: ObservableObject {
    
    enum Context {
        case categoryId(Int)
        case onSale
        case featured
        case byIds([Int])
        case search(String)
    }

    @Published var products: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    
    let headline: String?
    
    private let context: Context
    private var currentPage = 1
    private var totalPages: Int?
    private let api = WooCommerceAPIManager.shared

    var canLoadMore: Bool {
        guard let total = totalPages, !isLoading, !isLoadingMore else { return false }
        return currentPage <= total
    }

    init(context: Context, headline: String? = nil) {
        self.context = context
        self.headline = headline
    }
    
    func loadProducts() async {
        guard !isLoading else { return }
        
        self.currentPage = 1
        self.products = []
        self.totalPages = nil
        self.isLoading = true
        self.errorMessage = nil
        
        await fetchProductData()
        
        self.isLoading = false
    }
    
    func loadMoreProducts() async {
        guard canLoadMore else { return }
        
        self.isLoadingMore = true
        await fetchProductData()
        self.isLoadingMore = false
    }
    
    private func fetchProductData() async {
        do {
            // --- SCHRITT 1: BASIS-PRODUKTE LADEN (wie bisher) ---
            let response: WooCommerceProductsResponseContainer
            
            switch context {
            case .categoryId(let id):
                response = try await api.fetchProducts(categoryId: id, page: currentPage)
            case .onSale:
                response = try await api.fetchProducts(page: currentPage, onSale: true)
            case .featured:
                response = try await api.fetchProducts(page: currentPage, featured: true)
            case .byIds(let ids):
                // Hinweis: Paginierung macht bei einer festen ID-Liste oft keinen Sinn.
                // Wir laden auf Seite 1 alle angeforderten IDs.
                response = try await api.fetchProducts(page: 1, include: ids)
            case .search(let query):
                response = try await api.fetchProducts(page: currentPage, searchQuery: query)
            }
            
            var fetchedProducts = response.products
            
            // ===================================================================
            // **HIER IST DIE NEUE ANREICHERUNGS-PHASE**
            // ===================================================================
            // --- SCHRITT 2: PREISSPANNEN FÜR VARIABLE PRODUKTE LADEN ---
            try await withThrowingTaskGroup(of: (Int, String?).self) { group in
                for product in fetchedProducts where product.type == "variable" {
                    group.addTask {
                        let variations = try await self.api.fetchProductVariations(productId: product.id)
                        let range = PriceFormatter.calculatePriceRange(from: variations)
                        return (product.id, range)
                    }
                }
                
                // --- SCHRITT 3: ERGEBNISSE SAMMELN UND PRODUKTE AKTUALISIEREN ---
                for try await (productId, range) in group {
                    if let range = range, let index = fetchedProducts.firstIndex(where: { $0.id == productId }) {
                        fetchedProducts[index].priceRangeDisplay = range
                    }
                }
            }
            
            // --- SCHRITT 4: FINALE, ANGEREICHERTE PRODUKTE VERÖFFENTLICHEN ---
            if self.currentPage == 1 {
                self.products = fetchedProducts
            } else {
                self.products.append(contentsOf: fetchedProducts)
            }
            
            self.totalPages = response.totalPages
            self.currentPage += 1
            
        } catch let apiError as WooCommerceAPIError {
            self.errorMessage = apiError.localizedDescriptionForUser
        } catch {
            self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
        }
    }
}
