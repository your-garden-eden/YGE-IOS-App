// Path: Your-Garden-Eden-IOS/Features/Categories/ViewModels/CategoryViewModel.swift

import Foundation

@MainActor
class CategoryViewModel: ObservableObject {
    
    @Published private(set) var displayableCategories: [DisplayableMainCategory] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let wooAPIManager = WooCommerceAPIManager.shared

    init() {
        print("✅ CategoryViewModel initialized.")
    }
    
    func fetchCategories() async {
        guard !isLoading else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        print("▶️ CategoryViewModel: Fetching categories...")
        
        do {
            let topLevelCategories = try await wooAPIManager.fetchCategories(parent: 0)
            
            self.displayableCategories = AppNavigationData.items.compactMap { appNavItem -> DisplayableMainCategory? in
                if let matchingWooCategory = topLevelCategories.first(where: { $0.slug == appNavItem.mainCategorySlug }) {
                    return DisplayableMainCategory(id: matchingWooCategory.id, appItem: appNavItem)
                } else {
                    return nil
                }
            }
            
            print("👍 CategoryViewModel: Successfully loaded and mapped \(displayableCategories.count) categories.")
            
        } catch {
            self.errorMessage = "Kategorien konnten nicht geladen werden."
            print("❌ ERROR (Categories): \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
}
