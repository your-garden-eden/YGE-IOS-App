// ProductCategoryListViewModel.swift (oder dein korrekter ViewModel-Name)
import SwiftUI // Für @MainActor (ersetzt Combine für UI-Updates hier)
// import Combine // Nicht mehr zwingend für diesen spezifischen Code nötig, wenn @MainActor verwendet wird

@MainActor // Stellt sicher, dass @Published Properties und UI-bezogene Logik auf dem Main Actor laufen
class ProductCategoryListViewModel: ObservableObject {
    @Published var categories: [WooCommerceCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let wooAPIManager = WooCommerceAPIManager.shared // Wieder einkommentieren ist korrekt

    init() {
        print("ProductCategoryListViewModel initialized")
        // Optional: loadCategories() direkt hier aufrufen, wenn sie beim Start geladen werden sollen.
        // loadCategories()
    }

    func loadCategories(parent: Int? = nil) { // Standardmäßig nil für Hauptkategorien
        print("ProductCategoryListViewModel: loadCategories called - ruft APIManager auf.")
        
        // Properties auf dem Main Actor setzen (automatisch durch @MainActor auf der Klasse)
        self.isLoading = true
        self.errorMessage = nil
        // self.categories = [] // Optional: Kategorien leeren vor dem Neuladen, wenn gewünscht

        // Starte eine neue Swift Concurrency Task für den asynchronen API-Aufruf
        Task {
            do {
                // Rufe die async throws Methode im WooCommerceAPIManager auf
                // Die Parameter hier müssen mit denen in deiner WooCommerceAPIManager.getCategories Methode übereinstimmen
                let fetchedCategories = try await wooAPIManager.getCategories(
                    parent: parent,
                    hideEmpty: true, // Beispiel: Du kannst hier Standardwerte oder übergebene Werte verwenden
                    orderby: "menu_order", // Beispiel
                    order: "asc"           // Beispiel
                )
                
                // Wenn der Aufruf erfolgreich war, aktualisiere die @Published Properties
                // Dies geschieht automatisch auf dem Main Actor wegen @MainActor auf der Klasse.
                self.categories = fetchedCategories
                
                // Optionale Logik, falls keine Kategorien gefunden wurden (aber kein Fehler von der API kam)
                if fetchedCategories.isEmpty {
                    // Du könntest hier eine spezifische Nachricht setzen oder es einfach leer lassen
                    // self.errorMessage = "Keine Kategorien für diese Auswahl gefunden."
                    print("ProductCategoryListViewModel: Keine Kategorien empfangen, aber API-Aufruf war erfolgreich.")
                }
                
            } catch let apiError as WooCommerceAPIError { // Fange spezifische WooCommerceAPIError-Typen
                self.errorMessage = "Fehler beim Laden der Kategorien: \(apiError.localizedDescription)"
                print("ProductCategoryListViewModel API Error: \(apiError)")
            } catch { // Fange alle anderen (unerwarteten) Fehler
                self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten: \(error.localizedDescription)"
                print("ProductCategoryListViewModel Unknown Error: \(error)")
            }
            
            // Setze isLoading auf false, nachdem die Task abgeschlossen ist (Erfolg oder Fehler)
            self.isLoading = false
        }
    }
}
