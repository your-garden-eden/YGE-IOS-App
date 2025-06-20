// DATEI: ProductListViewModel.swift
// PFAD: Features/Products/ViewModels/List/ProductListViewModel.swift
// VERSION: FINAL - Alle Operationen integriert.

import Foundation
import Combine

@MainActor
class ProductListViewModel: ObservableObject {
    
    @Published var products: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var filterState = ProductFilterState()
    @Published private(set) var context: ProductListContext
    
    var headline: String?
    
    private var currentPage = 1
    private var totalPages: Int?
    private let api = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared
    private var cancellables = Set<AnyCancellable>()
    private let searchQuerySubject = PassthroughSubject<String, Never>()

    var canLoadMore: Bool {
        guard let totalPages = totalPages, !isLoading, !isLoadingMore, filterState.isPristine else { return false }
        return currentPage <= totalPages
    }

    init(context: ProductListContext, headline: String? = nil) {
        self.context = context
        self.headline = headline
        setupSearchDebouncing()
        logger.info("ProductListViewModel initialisiert mit Kontext: \(context).")
    }
    
    func search(for query: String) {
        logger.debug("Suchanfrage empfangen: '\(query)'. Weiterleitung an Debouncer.")
        searchQuerySubject.send(query)
    }
    
    func applyFilters() {
        logger.info("Filter werden angewendet.")
        resetAndReload()
    }
    
    func resetFilters() {
        logger.info("Filter werden zurückgesetzt.")
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
        logger.info("Lade mehr Produkte (Seite \(currentPage))...")
        isLoadingMore = true
        await fetchProductData()
        isLoadingMore = false
    }
    
    private func resetAndReload() {
        logger.info("Ladezustand wird zurückgesetzt und Daten werden neu geladen.")
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
                self.logger.info("Debounced Suche wird ausgeführt für: '\(trimmedQuery)'.")
                self.context = trimmedQuery.isEmpty ? .categoryId(0) : .search(trimmedQuery)
                self.resetAndReload()
            }
            .store(in: &cancellables)
    }
    
    private func fetchProductData() async {
        errorMessage = nil
        logger.info("Starte Produkt-API-Abruf für Seite \(currentPage) mit Kontext \(context).")
        
        do {
            let params = buildFilterParameters()
            let response = try await api.fetchProducts(params: params, page: currentPage)
            
            logger.info("\(response.products.count) Produkte auf Seite \(currentPage) von \(response.totalPages) empfangen.")
            
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
            logger.error("Fehler beim Abrufen der Produktdaten: \(apiError.localizedDescription)")
        } catch {
            self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
            logger.error("Unerwarteter Fehler beim Abrufen der Produktdaten: \(error.localizedDescription)")
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
        if filterState.selectedProductType != .all { params.productType = filterState.selectedProductType.apiValue }
        if filterState.minPrice > filterState.absolutePriceRange.lowerBound { params.minPrice = String(format: "%.2f", filterState.minPrice) }
        if filterState.maxPrice < filterState.absolutePriceRange.upperBound { params.maxPrice = String(format: "%.2f", filterState.maxPrice) }
        
        params.orderBy = filterState.selectedSortOption.apiValue.orderBy
        params.order = filterState.selectedSortOption.apiValue.order
        
        logger.debug("Erstelle API-Parameter.")
        return params
    }
    
    private func processProductVariations(for products: inout [WooCommerceProduct]) async throws {
        let variableProducts = products.filter { $0.type == "variable" }
        guard !variableProducts.isEmpty else { return }
        
        logger.info("Verarbeite Preisspannen für \(variableProducts.count) variable Produkte...")
        try await withThrowingTaskGroup(of: (productId: Int, range: String?).self) { group in
            for product in variableProducts {
                group.addTask {
                    let variations = try await self.api.fetchProductVariations(productId: product.id)
                    let range = PriceFormatter.calculatePriceRange(from: variations)
                    return (product.id, range)
                }
            }
            
            var processedCount = 0
            for try await (productId, range) in group {
                if let range = range, let index = products.firstIndex(where: { $0.id == productId }) {
                    products[index].priceRangeDisplay = range
                    processedCount += 1
                }
            }
            logger.info("Preisspannen-Verarbeitung abgeschlossen. \(processedCount) Produkte aktualisiert.")
        }
    }
}
