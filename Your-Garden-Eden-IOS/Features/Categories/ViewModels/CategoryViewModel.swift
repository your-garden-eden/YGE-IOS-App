import Foundation

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var topLevelCategories: [WooCommerceCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api = WooCommerceAPIManager.shared
    
    init() {
        print("✅ CategoryViewModel initialized.")
    }

    func fetchTopLevelCategories() async {
        // Nur laden, wenn die Liste leer ist und nicht bereits ein Ladevorgang läuft.
        guard topLevelCategories.isEmpty, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Schritt 1: Definiere die "erlaubten" Kategorien basierend auf unseren lokalen Daten.
            // Die Reihenfolge der Slugs in diesem Array definiert die finale Sortierung.
            let allowedSlugs = AppNavigationData.items.map { $0.mainCategorySlug }
            let allowedSlugsSet = Set(allowedSlugs)

            // Schritt 2: Lade ALLE Top-Level-Kategorien von der API.
            let allApiCategories = try await api.fetchCategories(parent: 0)
            
            // Schritt 3: Filtere die API-Ergebnisse, um nur die erlaubten Kategorien zu behalten.
            let filteredCategories = allApiCategories.filter { allowedSlugsSet.contains($0.slug) }
            
            // Schritt 4: Sortiere die gefilterten Kategorien exakt nach der Reihenfolge in `allowedSlugs`.
            self.topLevelCategories = filteredCategories.sorted { cat1, cat2 in
                guard let firstIndex = allowedSlugs.firstIndex(of: cat1.slug),
                      let secondIndex = allowedSlugs.firstIndex(of: cat2.slug) else {
                    return false
                }
                return firstIndex < secondIndex
            }
            
        } catch let apiError as WooCommerceAPIError {
            self.errorMessage = apiError.localizedDescriptionForUser
        } catch {
            self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
        }
        
        isLoading = false
    }
}
