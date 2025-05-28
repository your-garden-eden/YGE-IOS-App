// ProductCategoryListViewModel.swift
import SwiftUI

@MainActor
class ProductCategoryListViewModel: ObservableObject {
    @Published var categories: [WooCommerceCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let wooAPIManager = WooCommerceAPIManager.shared

    init() {
        print("ProductCategoryListViewModel initialized")
        // Um Kategorien direkt beim Start zu laden, rufe loadCategories() hier auf.
        // Zum Beispiel für Top-Level-Kategorien:
        // Task {
        //     await loadCategories() // oder loadCategories(parent: 0) wenn 0 für Top-Level steht
        // }
    }

    // Die Funktion kann jetzt 'async' sein, da sie 'await' verwendet.
    // Das @MainActor auf der Klasse stellt sicher, dass UI-Updates auf dem Main Thread passieren.
    func loadCategories(parent: Int? = nil) async {
        print("ProductCategoryListViewModel: loadCategories(parent: \(parent ?? -1)) called - ruft APIManager auf.")
        
        self.isLoading = true
        self.errorMessage = nil
        // self.categories = [] // Optional: Kategorien leeren

        do {
            // KORRIGIERTER AUFRUF:
            // 'orderby' und 'order' werden weggelassen, um die Standardwerte
            // "name" und "asc" aus WooCommerceAPIManager.getCategories zu verwenden.
            let fetchedCategories = try await wooAPIManager.getCategories(
                parent: parent,
                hideEmpty: true // Du kannst diesen Parameter bei Bedarf anpassbar machen
            )
            
            self.categories = fetchedCategories
            
            if fetchedCategories.isEmpty {
                print("ProductCategoryListViewModel: Keine Kategorien für parent: \(parent ?? -1) empfangen (API-Aufruf erfolgreich).")
            } else {
                print("ProductCategoryListViewModel: \(fetchedCategories.count) Kategorien für parent: \(parent ?? -1) geladen.")
            }
            
        } catch let apiError as WooCommerceAPIError {
            self.errorMessage = "Kategorien-Ladefehler: \(apiError.localizedDescription)"
            print("ProductCategoryListViewModel API Error (loadCategories): \(apiError)")
        } catch {
            self.errorMessage = "Unerwarteter Fehler (Kategorien): \(error.localizedDescription)"
            print("ProductCategoryListViewModel Unknown Error (loadCategories): \(error)")
        }
        
        self.isLoading = false
    }
}
