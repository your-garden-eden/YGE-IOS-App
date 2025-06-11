import SwiftUI

// Das Anzeigemodell ist einfach und wird jetzt korrekt befüllt.
struct DisplayableSubCategory: Identifiable, Hashable {
    let id: Int
    let label: String
}

@MainActor
class SubCategoryViewModel: ObservableObject {
    @Published var displayableSubCategories: [DisplayableSubCategory] = []
    @Published var isLoadingSubcategories = false
    @Published var subcategoryErrorMessage: String?
    @Published var products: [WooCommerceProduct] = []
    @Published var isLoadingProducts = false
    @Published var isLoadingMoreProducts = false
    @Published var productErrorMessage: String?
    
    private(set) var currentPage: Int = 1
    private(set) var totalPages: Int = 1
    private(set) var currentSubCategory: DisplayableSubCategory?
    let mainCategoryAppItem: AppNavigationItem
    private let parentWooCommerceCategoryID: Int
    private let apiManager = WooCommerceAPIManager.shared

    init(mainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        self.mainCategoryAppItem = mainCategoryAppItem
        self.parentWooCommerceCategoryID = parentWooCommerceCategoryID
    }

    func loadSubCategories() async {
        guard !isLoadingSubcategories else { return }
        isLoadingSubcategories = true
        subcategoryErrorMessage = nil
        
        do {
            let wooSubCategories = try await apiManager.fetchCategories(parent: parentWooCommerceCategoryID, hideEmpty: true)
            
            // FINALE KORREKTUR: Wir mappen den `name` der Kategorie auf das `label`.
            // Das sorgt dafür, dass z.B. "Markisen" angezeigt wird, nicht "sonnenschutz-markisen".
            self.displayableSubCategories = wooSubCategories.map {
                DisplayableSubCategory(id: $0.id, label: $0.name)
            }
        } catch {
            self.subcategoryErrorMessage = "Unterkategorien konnten nicht geladen werden."
        }
        self.isLoadingSubcategories = false
    }
    
    func loadProducts(for subCategory: DisplayableSubCategory? = nil, initialLoad: Bool) async {
        if let subCategory = subCategory { self.currentSubCategory = subCategory }
        guard let currentSubCategory = self.currentSubCategory else { return }
        if !initialLoad && (currentPage >= totalPages && totalPages != 0) { return }
        if (initialLoad && isLoadingProducts) || (!initialLoad && isLoadingMoreProducts) { return }

        if initialLoad {
            isLoadingProducts = true
            currentPage = 1
            products = []
            totalPages = 1
        } else {
            isLoadingMoreProducts = true
        }
        productErrorMessage = nil

        do {
            let container = try await apiManager.fetchProducts(categoryId: currentSubCategory.id, perPage: 10, page: currentPage)
            if initialLoad { products = container.products }
            else { products.append(contentsOf: container.products.filter { !products.contains($0) }) }
            totalPages = container.totalPages
            if currentPage < totalPages { currentPage += 1 }
        } catch {
            productErrorMessage = "Produkte konnten nicht geladen werden."
        }
        
        if initialLoad { isLoadingProducts = false }
        else { isLoadingMoreProducts = false }
    }
    
    func isLastProduct(_ product: WooCommerceProduct) -> Bool {
        return products.last?.id == product.id
    }
}
