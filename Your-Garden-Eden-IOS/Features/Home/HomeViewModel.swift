// DATEI: HomeViewModel.swift
// PFAD: Features/Home/ViewModels/HomeViewModel.swift
// VERSION: 1.1 (FINAL)

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var bestsellerProducts: [WooCommerceProduct] = []
    @Published var isLoadingBestsellers: Bool = false
    @Published var bestsellerErrorMessage: String?
    
    @Published var topLevelCategories: [WooCommerceCategory] = []
    @Published var isLoadingCategories: Bool = false
    @Published var categoryErrorMessage: String?
    
    private let api = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared

    func loadInitialData() async {
        guard bestsellerProducts.isEmpty && topLevelCategories.isEmpty else { return }
        logger.info("Laden der initialen Daten für die Home-Ansicht gestartet.")
        
        isLoadingBestsellers = true
        isLoadingCategories = true
        
        async let fetchBestsellersTask: () = fetchBestsellers()
        async let fetchCategoriesTask: () = fetchTopLevelCategories()
        _ = await [fetchBestsellersTask, fetchCategoriesTask]
        
        isLoadingBestsellers = false
        isLoadingCategories = false
        logger.info("Initiales Laden für die Home-Ansicht abgeschlossen.")
    }
    
    func getDisplayName(for category: WooCommerceCategory) -> String {
        return NavigationData.items.first { $0.mainCategorySlug == category.slug }?.label ?? category.name.strippingHTML()
    }

    private func fetchBestsellers() async {
        self.bestsellerErrorMessage = nil
        
        do {
            var params = ProductFilterParameters()
            params.orderBy = "popularity"
            params.order = "desc"
            
            let container = try await api.fetchProducts(params: params, page: 1, perPage: 10)
            
            var seenIDs = Set<Int>()
            var uniqueProducts = container.products.filter { seenIDs.insert($0.id).inserted }
            
            try await self.processProductVariations(for: &uniqueProducts)
            self.bestsellerProducts = uniqueProducts
        } catch {
            self.bestsellerErrorMessage = "Die Bestseller konnten nicht geladen werden."
            logger.error("Fehler beim Laden der Bestseller: \(error.localizedDescription)")
        }
    }
    
    private func fetchTopLevelCategories() async {
        self.categoryErrorMessage = nil
        
        do {
            let allApiCategories = try await api.fetchCategories(parent: 0)
            let allowedSlugs = NavigationData.items.map { $0.mainCategorySlug }
            let allowedSlugsSet = Set(allowedSlugs)
            let filteredCategories = allApiCategories.filter { allowedSlugsSet.contains($0.slug) }
            
            self.topLevelCategories = filteredCategories.sorted { cat1, cat2 in
                guard let firstIndex = allowedSlugs.firstIndex(of: cat1.slug),
                      let secondIndex = allowedSlugs.firstIndex(of: cat2.slug) else { return false }
                return firstIndex < secondIndex
            }
        } catch {
            self.categoryErrorMessage = "Die Kategorien konnten nicht geladen werden."
            logger.error("Fehler beim Laden der Top-Level-Kategorien: \(error.localizedDescription)")
        }
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
