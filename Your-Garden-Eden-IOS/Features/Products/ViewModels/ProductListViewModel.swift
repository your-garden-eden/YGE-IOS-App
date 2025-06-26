// DATEI: ProductListViewModel.swift
// PFAD: Features/Products/ViewModels/ProductListViewModel.swift
// VERSION: 1.1 (FINAL)

import Foundation
import Combine

@MainActor
class ProductListViewModel: ObservableObject {
    
    @Published var products: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var filterState: ProductFilterState
    @Published private(set) var context: ProductListContext
    
    var headline: String?
    
    private var currentPage = 1
    private var totalPages: Int?
    private let api = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared
    private var fetchTask: Task<Void, Never>?

    var canLoadMore: Bool {
        guard let totalPages = totalPages, !isLoading, !isLoadingMore else { return false }
        return currentPage <= totalPages
    }

    init(context: ProductListContext, headline: String? = nil) {
        self.context = context
        self.headline = headline
        self.filterState = ProductFilterState()
    }
    
    func search(for query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        self.context = trimmedQuery.isEmpty ? .categoryId(0) : .search(trimmedQuery) // Simplified context switch
        resetAndReload()
    }

    func applyFilters() {
        resetAndReload()
    }
    
    func resetFilters() {
        filterState.reset()
        resetAndReload()
    }

    func loadProducts() async {
        guard !isLoading else { return }
        fetchTask?.cancel()
        
        isLoading = true
        await fetchProductData()
        isLoading = false
    }

    func loadMoreProducts() async {
        guard canLoadMore else { return }
        
        isLoadingMore = true
        await fetchProductData()
        isLoadingMore = false
    }
    
    private func resetAndReload() {
        currentPage = 1
        totalPages = nil
        products.removeAll()
        Task { await loadProducts() }
    }
    
    private func fetchProductData() async {
        errorMessage = nil
        
        do {
            let params = buildFilterParameters()
            let response = try await api.fetchProducts(params: params, page: currentPage, perPage: 10)
            
            guard !Task.isCancelled else { return }
            
            var fetchedProducts = response.products
            try await processProductVariations(for: &fetchedProducts)
            
            if currentPage == 1 { products = fetchedProducts }
            else { products.append(contentsOf: fetchedProducts) }
            
            self.totalPages = response.totalPages
            self.currentPage += 1
            
        } catch is CancellationError {
            logger.notice("Task abgebrochen.")
        } catch {
            if !Task.isCancelled { self.errorMessage = "Produkte konnten nicht geladen werden." }
        }
    }
    
    private func buildFilterParameters() -> ProductFilterParameters {
        var params = ProductFilterParameters()
        switch context {
            case .categoryId(let id): if id != 0 { params.categoryId = id }
            case .onSale: params.onSale = true
            case .featured: params.featured = true
            case .byIds(let ids): params.include = ids
            case .search(let query): params.searchQuery = query
        }
        
        params.stockStatus = filterState.showOnlyAvailable ? .instock : nil
        params.productType = filterState.selectedProductType.apiValue
        params.orderBy = filterState.selectedSortOption.apiValue.orderBy
        params.order = filterState.selectedSortOption.apiValue.order
        
        return params
    }
    
    private func processProductVariations(for products: inout [WooCommerceProduct]) async throws {
        let variableProducts = products.filter { $0.type == "variable" }
        guard !variableProducts.isEmpty else { return }
        
        try await withThrowingTaskGroup(of: (productId: Int, range: String?).self) { group in
            for product in variableProducts {
                group.addTask {
                    let variations = try await self.api.fetchProductVariations(productId: product.id)
                    let range = PriceFormatter.calculatePriceRange(from: variations)
                    return (product.id, range)
                }
            }
            
            for try await (productId, range) in group {
                if Task.isCancelled { break }
                if let range = range, let index = products.firstIndex(where: { $0.id == productId }) {
                    products[index].priceRangeDisplay = range
                }
            }
        }
    }
}
