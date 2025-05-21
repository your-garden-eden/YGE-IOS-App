import Foundation
import Combine

class ProductCategoryListViewModel: ObservableObject {
    @Published var categories: [WooCommerceCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init() {
        print("ProductCategoryListViewModel initialized - Datenladen vorerst deaktiviert.")
    }

    func loadCategories() {
        print("ProductCategoryListViewModel: loadCategories called - Laden ist aktuell deaktiviert.")
        self.isLoading = true
        self.errorMessage = nil
        self.categories = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            // Optional: Setze eine Nachricht, wenn keine Daten geladen werden (wird in der View angezeigt)
            // if self.categories.isEmpty {
            //     self.errorMessage = "Kategorieladefunktion ist noch nicht aktiv."
            // }
        }
    }
}
