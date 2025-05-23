// CategoryViewModel.swift
import SwiftUI // Für @MainActor
// import Combine // Nur wenn du es explizit für etwas anderes brauchst

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [WooCommerceCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let wooAPIManager = WooCommerceAPIManager.shared

    init() {
        print("CategoryViewModel initialized")
    }

    // Die Funktion muss exakt so definiert sein:
    func fetchCategories(parent: Int? = nil) { // Parameter sind optional
        print("CategoryViewModel: fetchCategories called...")
        self.isLoading = true
        self.errorMessage = nil
        // self.categories = [] // Optional, wenn du sie immer leeren willst

        Task {
            do {
                let fetchedCategories = try await wooAPIManager.getCategories(
                    parent: parent,
                    hideEmpty: true, // Stelle sicher, dass alle Parameter hier
                    orderby: "menu_order", // mit der Definition in
                    order: "asc"           // WooCommerceAPIManager.getCategories übereinstimmen
                )
                self.categories = fetchedCategories
                // ... (Rest der Logik)
            } catch {
                // ... (Fehlerbehandlung)
            }
            self.isLoading = false
        }
    }
}
