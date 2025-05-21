import Foundation
import Combine

class ProductCategoryListViewModel: ObservableObject {
    @Published var categories: [WooCommerceCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let wooAPIManager = WooCommerceAPIManager.shared // Wieder einkommentieren

    init() {
        print("ProductCategoryListViewModel initialized")
    }

    func loadCategories(parent: Int? = nil) {
        print("ProductCategoryListViewModel: loadCategories called - ruft APIManager auf.")
        self.isLoading = true
        self.errorMessage = nil
        // self.categories = [] // Optional leeren

        wooAPIManager.getCategories(parent: parent) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let fetchedCategories):
                    self.categories = fetchedCategories
                    if fetchedCategories.isEmpty && self.errorMessage == nil { // Nur setzen, wenn kein anderer Fehler da ist
                        self.errorMessage = "Keine Kategorien vom APIManager erhalten (evtl. Simulation)."
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
