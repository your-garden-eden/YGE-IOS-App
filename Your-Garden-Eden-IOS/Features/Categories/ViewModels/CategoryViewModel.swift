import SwiftUI

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [WooCommerceCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let wooAPIManager = WooCommerceAPIManager.shared

    private let desiredMainCategories: [String] = [
        "gartenmoebel",
        "sonnenschutz",
        "wasser-im-garten",
        "heizen-feuer",
        "gartenhelfer-aufbewahrung",
        "deko-licht",
        "pflanzen-anzucht",
        "fuer-die-ganze-grossen"
    ]

    init() {
        print("CategoryViewModel initialized.")
    }

    func fetchMainCategories() {
        print("CategoryViewModel: fetchMainCategories called...")
        self.isLoading = true
        self.errorMessage = nil

        Task {
            do {
                // KORREKTUR: 'getCategories' -> 'fetchCategories' und Anpassung der Parameter.
                let allTopLevelCategories = try await wooAPIManager.fetchCategories(parent: 0, hideEmpty: false)
                
                print("CategoryViewModel: Fetched \(allTopLevelCategories.count) top-level categories.")

                var processedCategories: [WooCommerceCategory] = []
                for desiredSlug in desiredMainCategories {
                    if let matchedCategory = allTopLevelCategories.first(where: { $0.slug == desiredSlug }) {
                        processedCategories.append(matchedCategory)
                    }
                }
                
                self.categories = processedCategories
                
            } catch let error as WooCommerceAPIError {
                self.errorMessage = error.localizedDescriptionForUser // Deine bestehende Fehlerlogik
                print("CategoryViewModel Error (WooCommerceAPIError): \(error.debugDescription)") // Deine bestehende Fehlerlogik
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten."
                print("CategoryViewModel Error (Unknown): \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
