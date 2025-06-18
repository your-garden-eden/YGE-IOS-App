// DATEI: ProductListViewModel.swift
// PFAD: Features/Products/ViewModels/List/ProductListViewModel.swift
// ZWECK: Verwaltet den Zustand und die Logik für die `ProductListView`,
//        einschließlich Filtern, Suchen, Sortieren und Paginierung.

import Foundation
import Combine

@MainActor
class ProductListViewModel: ObservableObject {
    
    /// Definiert den primären Kontext für das Laden von Produkten (z.B. eine Kategorie, Suche, etc.).
    enum Context: Equatable {
        case categoryId(Int)
        case onSale, featured, byIds([Int]), search(String)
    }

    // MARK: - Veröffentlichte Eigenschaften
    @Published var products: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var filterState = ProductFilterState()
    @Published private(set) var context: Context
    
    var headline: String?
    
    // MARK: - Private Eigenschaften
    private var currentPage = 1
    private var totalPages: Int?
    private let api = WooCommerceAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
    private let searchQuerySubject = PassthroughSubject<String, Never>()

    var canLoadMore: Bool {
        // Die Paginierung wird deaktiviert, wenn Filter aktiv sind, da die Seitenzahlen dann ungenau wären.
        guard let totalPages = totalPages, !isLoading, !isLoadingMore, filterState.isPristine else { return false }
        return currentPage <= totalPages
    }

    // MARK: - Initialisierung
    init(context: Context, headline: String? = nil) {
        self.context = context
        self.headline = headline
        setupSearchDebouncing()
    }
    
    // MARK: - Öffentliche API für Views
    
    func search(for query: String) {
        searchQuerySubject.send(query)
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
    
    // MARK: - Private Logik
    
    private func resetAndReload() {
        currentPage = 1
        products = []
        Task { await loadProducts() }
    }
    
    private func setupSearchDebouncing() {
        searchQuerySubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchQuery in
                guard let self = self else { return }
                
                let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespaces)
                self.context = trimmedQuery.isEmpty ? .categoryId(0) : .search(trimmedQuery) // Annahme: Leere Suche -> alle Produkte
                self.resetAndReload()
            }
            .store(in: &cancellables)
    }
    
    private func fetchProductData() async {
        errorMessage = nil
        
        do {
            let params = buildFilterParameters()
            let response = try await api.fetchProducts(params: params, page: currentPage)
            
            var fetchedProducts = response.products
            try await processProductVariations(for: &fetchedProducts)
            
            if currentPage == 1 {
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
    
    private func buildFilterParameters() -> ProductFilterParameters {
        var params = ProductFilterParameters()
        
        switch context {
            case .categoryId(let id): if id != 0 { params.categoryId = id }
            case .onSale: params.onSale = true
            case .featured: params.featured = true
            case .byIds(let ids): params.include = ids
            case .search(let query): params.searchQuery = query
        }
        
        if filterState.showOnlyAvailable { params.stockStatus = .instock }
        if filterState.selectedProductType != .all { params.productType = filterState.selectedProductType.rawValue }
        if filterState.minPrice > filterState.absolutePriceRange.lowerBound { params.minPrice = String(format: "%.2f", filterState.minPrice) }
        if filterState.maxPrice < filterState.absolutePriceRange.upperBound { params.maxPrice = String(format: "%.2f", filterState.maxPrice) }
        
        params.orderBy = filterState.selectedSortOption.apiValue.orderBy
        params.order = filterState.selectedSortOption.apiValue.order
        
        return params
    }
    
    private func processProductVariations(for products: inout [WooCommerceProduct]) async throws {
        try await withThrowingTaskGroup(of: (productId: Int, range: String?).self) { group in
            for product in products where product.type == "variable" {
                group.addTask {
                    let variations = try await self.api.fetchProductVariations(productId: product.id)
                    let range = PriceFormatter.calculatePriceRange(from: variations)
                    return (product.id, range)
                }
            }
            
            for try await (productId, range) in group {
                if let range = range, let index = products.firstIndex(where: { $0.id == productId }) {
                    products[index].priceRangeDisplay = range
                }
            }
        }
    }
}
