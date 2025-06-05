import SwiftUI

struct DisplayableSubCategory: Identifiable, Hashable {
    let id: Int // WooCommerce Category ID
    let label: String
    let iconFilename: String?
}

@MainActor
class SubCategoryViewModel: ObservableObject {
    // MARK: - Subcategory State
    @Published var displayableSubCategories: [DisplayableSubCategory] = []
    @Published var isLoadingSubcategories = false
    @Published var subcategoryErrorMessage: String?

    // MARK: - Product List State
    @Published var products: [WooCommerceProduct] = []
    @Published var isLoadingProducts = false // Für initialen Produkt-Load
    @Published var isLoadingMoreProducts = false // Für Paginierung
    @Published var productErrorMessage: String?
    
    private(set) var currentPage: Int = 1
    private(set) var totalPages: Int = 1
    private(set) var currentProductCategoryId: Int?

    // MARK: - General Properties
    let mainCategoryAppItem: AppNavigationItem
    private let parentWooCommerceCategoryID: Int
    private let apiManager = WooCommerceAPIManager.shared

    init(mainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        self.mainCategoryAppItem = mainCategoryAppItem
        self.parentWooCommerceCategoryID = parentWooCommerceCategoryID
    }

    // Lädt die Liste der Unterkategorien
    func loadSubCategories() async {
        guard !isLoadingSubcategories else { return }
        isLoadingSubcategories = true
        subcategoryErrorMessage = nil
        displayableSubCategories = []
        
        do {
            let wooSubCategories = try await apiManager.getCategories(parent: parentWooCommerceCategoryID, perPage: 100, hideEmpty: true)
            guard let definedSubItems = mainCategoryAppItem.subItems else {
                self.isLoadingSubcategories = false
                return
            }
            
            var result: [DisplayableSubCategory] = []
            for definedItem in definedSubItems {
                // Flexibler Abgleich, falls WooCommerce-Slug anders ist als der volle App-Slug
                if let matched = wooSubCategories.first(where: { definedItem.linkSlug.hasSuffix($0.slug) }) {
                    result.append(DisplayableSubCategory(id: matched.id, label: definedItem.label, iconFilename: definedItem.iconFilename))
                }
            }
            self.displayableSubCategories = result
        } catch {
            self.subcategoryErrorMessage = "Unterkategorien konnten nicht geladen werden."
        }
        self.isLoadingSubcategories = false
    }
    
    // Lädt Produkte
    func loadProducts(for subCategory: DisplayableSubCategory, initialLoad: Bool) async {
        let categoryId = subCategory.id
        
        if !initialLoad && (currentPage > totalPages && totalPages != 0) { return }
        if (initialLoad && isLoadingProducts) || (!initialLoad && isLoadingMoreProducts) { return }

        if initialLoad {
            self.isLoadingProducts = true
            self.currentPage = 1
            self.products = []
            self.currentProductCategoryId = categoryId
            self.totalPages = 1 // Zurücksetzen
        } else {
            self.isLoadingMoreProducts = true
        }
        self.productErrorMessage = nil

        do {
            let container = try await apiManager.getProducts(categoryId: categoryId, perPage: 10, page: currentPage)
            let newProducts = container.products
            
            if initialLoad {
                self.products = newProducts
            } else {
                let existingIDs = Set(self.products.map { $0.id })
                let uniqueNew = newProducts.filter { !existingIDs.contains($0.id) }
                self.products.append(contentsOf: uniqueNew)
            }
            
            self.totalPages = container.totalPages
            if self.currentPage <= self.totalPages {
                self.currentPage += 1
            }
        } catch {
            self.productErrorMessage = "Produkte konnten nicht geladen werden."
        }
        
        if initialLoad { self.isLoadingProducts = false }
        else { self.isLoadingMoreProducts = false }
    }
    
    // Infinite Scroll Trigger
    func loadMoreProductsIfNeeded(currentItem product: WooCommerceProduct?) async {
        guard let currentCatId = self.currentProductCategoryId else { return }
        guard let product = product else { return }
        
        let thresholdIndex = products.index(products.endIndex, offsetBy: -5, limitedBy: products.startIndex) ?? products.startIndex
        guard products.firstIndex(where: { $0.id == product.id }) == thresholdIndex else { return }
        
        // Dummy-Objekt wird nur für die ID benötigt
        await loadProducts(for: DisplayableSubCategory(id: currentCatId, label: "", iconFilename: nil), initialLoad: false)
    }
}
