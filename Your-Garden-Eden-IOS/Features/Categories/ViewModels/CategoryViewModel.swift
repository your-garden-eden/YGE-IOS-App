// Dateiname: Features/Categories/ViewModels/CategoryViewModel.swift

import Foundation

@MainActor
class CategoryViewModel: ObservableObject {
    
    @Published var displayableCategories: [DisplayableMainCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let wooAPIManager = WooCommerceAPIManager.shared

    init() {
        print("✅ CategoryViewModel: Initialized. Automatically fetching categories.")
        self.isLoading = true
        
        Task {
            await loadCategories()
        }
    }
    
    private func loadCategories() async {
        errorMessage = nil
        
        do {
            let wooCommerceCategories = try await wooAPIManager.fetchCategories(parent: 0)
            let categoryIdMap = Dictionary(uniqueKeysWithValues: wooCommerceCategories.map { ($0.slug, $0.id) })
            
            let mergedCategories: [DisplayableMainCategory] = AppNavigationData.items.compactMap { appItem in
                if let categoryID = categoryIdMap[appItem.mainCategorySlug] {
                    // Verwendet jetzt die globale DisplayableMainCategory-Struktur
                    return DisplayableMainCategory(id: categoryID, appItem: appItem)
                } else {
                    print("⚠️ WARNUNG: Statische Kategorie '\(appItem.mainCategorySlug)' nicht auf dem Server gefunden.")
                    return nil
                }
            }
            self.displayableCategories = mergedCategories
            print("👍 CategoryViewModel: Successfully loaded \(mergedCategories.count) displayable categories.")
        } catch {
            print("❌ FEHLER (Kategorien): \(error.localizedDescription)")
            self.errorMessage = "Die Kategorien konnten nicht geladen werden."
        }
        
        self.isLoading = false
    }
}
