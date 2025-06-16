import Foundation

@MainActor
class SubCategoryListViewModel: ObservableObject {
    @Published var displayableSubCategories: [DisplayableSubCategory] = []
    
    let mainCategoryAppItem: AppNavigationItem
    let parentWooCommerceCategoryID: Int
    
    init(mainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        self.mainCategoryAppItem = mainCategoryAppItem
        self.parentWooCommerceCategoryID = parentWooCommerceCategoryID
        loadSubCategoriesFromLocalData()
    }
    
    private func loadSubCategoriesFromLocalData() {
        guard let subItems = mainCategoryAppItem.subItems else {
            self.displayableSubCategories = []
            return
        }
        
        self.displayableSubCategories = subItems.map {
            DisplayableSubCategory(label: $0.label, count: 0, slug: $0.linkSlug)
        }
    }
}
