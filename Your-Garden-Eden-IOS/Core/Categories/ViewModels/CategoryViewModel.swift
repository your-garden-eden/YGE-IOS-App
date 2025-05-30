// Core/Categories/ViewModels/CategoryViewModel.swift
import SwiftUI

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [WooCommerceCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let wooAPIManager = WooCommerceAPIManager.shared

    // Vordefinierte Reihenfolge und Slugs der Hauptkategorien
    // Wir verwenden den `label` aus deinen NavItems für die Anzeige, falls der API-Name mal abweicht,
    // aber primär filtern wir über den `slug`.
    private let desiredMainCategories: [(slug: String, displayLabel: String)] = [
        ("gartenmoebel", "Gartenmöbel"),
        ("sonnenschutz", "Sonnenschutz"),
        ("wasser-im-garten", "Wasser im Garten"),
        ("heizen-feuer", "Heizen & Feuer"),
        ("gartenhelfer-aufbewahrung", "Gartenhelfer & Aufbewahrung"),
        ("deko-licht", "Dekoration & Licht"),
        ("pflanzen-anzucht", "Pflanzen & Anzucht"),
        ("fuer-die-ganze-grossen", "Spiel & Spaß") // Slug "fuer-die-ganze-grossen" mit Label "Spiel & Spaß"
    ]

    init() {
        print("CategoryViewModel (Core/Categories) initialized.")
        // Lade Hauptkategorien beim Initialisieren
        // fetchMainCategories() // Wird jetzt in .onAppear der View aufgerufen
    }

    func fetchMainCategories() {
        print("CategoryViewModel: fetchMainCategories called...")
        self.isLoading = true
        self.errorMessage = nil
        // self.categories = [] // Optional: Leeren vor dem Neuladen

        Task {
            do {
                // 1. Alle Top-Level-Kategorien von der API abrufen
                // Annahme: parent: 0 oder nil holt Top-Level Kategorien.
                // `hideEmpty: false` könnte hier sinnvoll sein, falls eine Hauptkategorie mal temporär leer ist,
                // aber trotzdem angezeigt werden soll. Passe das nach Bedarf an.
                let allTopLevelCategories = try await wooAPIManager.getCategories(
                    parent: 0,      // Für Top-Level Kategorien
                    perPage: 100,   // Ausreichend hohe Zahl, um alle Top-Level zu bekommen
                    hideEmpty: false // Hauptkategorien auch anzeigen, wenn sie (noch) leer sind
                )
                print("CategoryViewModel: Fetched \(allTopLevelCategories.count) top-level categories from API.")

                // 2. Filtern und ordnen basierend auf unserer `desiredMainCategories` Liste
                var processedCategories: [WooCommerceCategory] = []
                for desiredCategoryInfo in desiredMainCategories {
                    if let matchedCategory = allTopLevelCategories.first(where: { $0.slug == desiredCategoryInfo.slug }) {
                        // Optional: Wenn du den Anzeigenamen aus deiner `navItems`-Struktur erzwingen willst,
                        // auch wenn der API-Name anders ist:
                        // var categoryToAdd = matchedCategory
                        // categoryToAdd.name = desiredCategoryInfo.displayLabel
                        // processedCategories.append(categoryToAdd)
                        processedCategories.append(matchedCategory)
                    } else {
                        print("CategoryViewModel: Warning - Main category with slug '\(desiredCategoryInfo.slug)' (Label: '\(desiredCategoryInfo.displayLabel)') not found among fetched top-level categories.")
                    }
                }
                
                self.categories = processedCategories
                
                if processedCategories.isEmpty && !allTopLevelCategories.isEmpty {
                    print("CategoryViewModel: No desired main categories matched the fetched top-level categories.")
                    // self.errorMessage = "Die gewünschten Hauptkategorien konnten nicht geladen werden."
                } else if processedCategories.isEmpty {
                     print("CategoryViewModel: No main categories to display (either not found or API returned no top-level).")
                } else {
                    print("CategoryViewModel: Successfully processed and ordered \(processedCategories.count) main categories.")
                }
                
            } catch let error as WooCommerceAPIError {
                self.errorMessage = "Fehler beim Laden der Hauptkategorien: \(error.localizedDescription)"
                print("CategoryViewModel Error (WooCommerceAPIError): \(error.localizedDescription)")
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
                print("CategoryViewModel Error (Unknown): \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
