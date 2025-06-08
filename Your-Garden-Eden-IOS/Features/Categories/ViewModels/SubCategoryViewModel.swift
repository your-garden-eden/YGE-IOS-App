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
    
    // Wir speichern die ausgewählte Unterkategorie hier, um sie nicht in der View übergeben zu müssen.
    private(set) var currentSubCategory: DisplayableSubCategory?

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
    func loadProducts(for subCategory: DisplayableSubCategory? = nil, initialLoad: Bool) async {
        // Wenn eine neue Unterkategorie gesetzt wird, merken wir sie uns
        if let subCategory = subCategory {
            self.currentSubCategory = subCategory
        }
        
        // Stellen sicher, dass wir eine Kategorie haben, für die wir laden können
        guard let currentSubCategory = self.currentSubCategory else { return }
        
        if !initialLoad && (currentPage > totalPages && totalPages != 0) { return }
        if (initialLoad && isLoadingProducts) || (!initialLoad && isLoadingMoreProducts) { return }

        if initialLoad {
            self.isLoadingProducts = true
            self.currentPage = 1
            self.products = []
            self.totalPages = 1
        } else {
            self.isLoadingMoreProducts = true
        }
        self.productErrorMessage = nil

        do {
            let container = try await apiManager.getProducts(categoryId: currentSubCategory.id, perPage: 10, page: currentPage)
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
    
    // --- NEUE HELPER FUNKTION ---
    // Prüft, ob ein Produkt das letzte in der Liste ist.
    func isLastProduct(_ product: WooCommerceProduct) -> Bool {
        return products.last?.id == product.id
    }
}
