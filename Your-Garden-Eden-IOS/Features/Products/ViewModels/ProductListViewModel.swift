import Foundation
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let categoryId: Int
    let categoryName: String

    init(categoryId: Int, categoryName: String) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        print("ProductListViewModel initialized for categoryID: \(categoryId), name: \(categoryName) - Datenladen vorerst deaktiviert.")
    }

    func loadProducts() {
        print("ProductListViewModel: loadProducts called for categoryID: \(categoryId) - Laden ist aktuell deaktiviert.")
        self.isLoading = true
        self.errorMessage = nil
        self.products = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            // Optional: Setze eine Nachricht
            // if self.products.isEmpty {
            //     self.errorMessage = "Produktladefunktion für diese Kategorie ist noch nicht aktiv."
            // }
        }
    }
}
