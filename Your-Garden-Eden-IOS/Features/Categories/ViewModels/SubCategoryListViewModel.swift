// Path: Your-Garden-Eden-IOS/Features/Categories/ViewModels/SubCategoryListViewModel.swift

import Foundation

@MainActor
class SubCategoryListViewModel: ObservableObject {
    @Published var displayableSubCategories: [DisplayableSubCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let mainCategoryAppItem: AppNavigationItem
    let parentWooCommerceCategoryID: Int
    private let apiManager = WooCommerceAPIManager.shared
    
    init(mainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        self.mainCategoryAppItem = mainCategoryAppItem
        self.parentWooCommerceCategoryID = parentWooCommerceCategoryID
    }
    
    func loadSubCategories() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let subCategories = try await apiManager.fetchCategories(parent: parentWooCommerceCategoryID)
            self.displayableSubCategories = subCategories.map {
                DisplayableSubCategory(id: $0.id, label: $0.name.strippingHTML(), count: $0.count)
            }
        } catch {
            self.errorMessage = "Unterkategorien konnten nicht geladen werden."
            print("🔴 SubCategoryListViewModel Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
