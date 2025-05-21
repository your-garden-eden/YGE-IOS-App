import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    // @Published var featuredProducts: [WooCommerceProduct] = [] // Vorerst auskommentiert

    init() {
        print("HomeViewModel initialized - Datenladen vorerst deaktiviert.")
    }

    func loadDataForHomeView() {
        print("HomeViewModel: loadDataForHomeView called - Laden ist aktuell deaktiviert.")
        self.isLoading = true
        self.errorMessage = nil
        // self.featuredProducts = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            // self.errorMessage = "Datenladen für Home ist noch nicht implementiert."
        }
    }
}
