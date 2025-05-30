//
//  DisplayableSubCategory.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 30.05.25.
//


// Features/Categories/ViewModels/SubCategoryViewModel.swift
import SwiftUI
import Combine // Für AnyCancellable, falls wir es später brauchen

// Wrapper-Struct, um unsere statischen AppSubNavigationItem-Definitionen
// mit den dynamisch geladenen WooCommerceCategory-Objekten zu verbinden.
struct DisplayableSubCategory: Identifiable, Hashable {
    let id: String // Wir verwenden den linkSlug des AppSubNavigationItem als stabile ID
    let label: String
    let iconName: String? // Name des Icons aus Assets oder nil
    let wooCommerceCategoryID: Int? // ID der WooCommerce-Kategorie, falls gefunden
    let wooCommerceCategorySlug: String? // Slug der WooCommerce-Kategorie, falls gefunden
    // Du könntest hier auch das ganze wooCategory-Objekt speichern, wenn mehr Infos direkt gebraucht werden
}

@MainActor
class SubCategoryViewModel: ObservableObject {
    @Published var displayableSubCategories: [DisplayableSubCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var navigationTitle: String = ""

    private let wooAPIManager = WooCommerceAPIManager.shared
    private var appNavigationItem: AppNavigationItem // Das ausgewählte Hauptkategorie-Item aus AppNavigationData

    // Initializer, der das ausgewählte AppNavigationItem (Hauptkategorie) entgegennimmt
    init(appNavigationItem: AppNavigationItem) {
        self.appNavigationItem = appNavigationItem
        self.navigationTitle = appNavigationItem.label // Setze den Titel der View
        print("SubCategoryViewModel initialized for main category: '\(appNavigationItem.label)' with slug: '\(appNavigationItem.mainCategorySlug)'")
    }

    // Diese Funktion wird aufgerufen, um die Unterkategorien zu laden.
    // Sie benötigt die WooCommerce-ID der übergeordneten Hauptkategorie.
    func fetchSubCategories(parentWooCommerceCategoryID: Int) {
        guard let definedSubItems = appNavigationItem.subItems, !definedSubItems.isEmpty else {
            print("SubCategoryViewModel: No subItems defined in AppNavigationData for '\(appNavigationItem.label)'.")
            self.displayableSubCategories = []
            // Optional: Eine Meldung für den Benutzer setzen, wenn keine Unterkategorien definiert sind.
            // self.errorMessage = "Für diese Kategorie sind keine Unterkategorien definiert."
            return
        }

        print("SubCategoryViewModel: Attempting to load WooCommerce subcategories for parent ID \(parentWooCommerceCategoryID) ('\(appNavigationItem.label)'). Will match against \(definedSubItems.count) defined sub items.")
        self.isLoading = true
        self.errorMessage = nil
        self.displayableSubCategories = [] // Leeren vor dem Laden

        Task {
            do {
                // 1. Lade alle WooCommerce-Unterkategorien für die gegebene parentWooCommerceCategoryID
                let fetchedWooSubCategories = try await wooAPIManager.getCategories(
                    parent: parentWooCommerceCategoryID,
                    perPage: 100, // Annahme: Nicht mehr als 100 Unterkategorien pro Hauptkategorie
                    hideEmpty: false // Wichtig: Auch Unterkategorien anzeigen, die ggf. (noch) keine Produkte haben
                )
                print("SubCategoryViewModel: Fetched \(fetchedWooSubCategories.count) WooCommerce subcategories from API for parent ID \(parentWooCommerceCategoryID).")

                var tempDisplayableCategories: [DisplayableSubCategory] = []

                // 2. Gehe durch unsere vordefinierten Unterkategorien (AppSubNavigationItem)
                for appSubItem in definedSubItems {
                    // 3. Finde die passende WooCommerce-Kategorie für jedes AppSubNavigationItem
                    //    Der Abgleich erfolgt über den Slug.
                    let matchedWooCategory = fetchedWooSubCategories.first { wooCategory in
                        // Wir vergleichen den `linkSlug` aus `appSubItem` (z.B. "gartenmoebel-sofas")
                        // mit dem `slug` aus `wooCategory`.
                        // Der WooCommerce-Slug für Unterkategorien enthält manchmal NICHT den Slug der Hauptkategorie.
                        // Beispiel: Hauptkategorie "Gartenmöbel" (Slug "gartenmoebel")
                        // Unterkategorie "Sofas" (App-Slug "gartenmoebel-sofas", WooCommerce-Slug könnte nur "sofas" sein)
                        // Daher ist ein direkter Gleichheitsvergleich nicht immer zielführend.
                        // Wir prüfen, ob der wooCategory.slug dem Ende unseres appSubItem.linkSlug entspricht.
                        
                        // Verbesserter Slug-Abgleich:
                        let appSlug = appSubItem.linkSlug.lowercased()
                        let wooSlug = wooCategory.slug.lowercased()

                        // Direkter Match (wenn WooCommerce-Slug den vollen Pfad hat oder identisch ist)
                        if appSlug == wooSlug { return true }
                        
                        // Match, wenn der WooCommerce-Slug ein Suffix des App-Slugs ist
                        // z.B. appSlug = "gartenmoebel-sofas", wooSlug = "sofas"
                        if appSlug.hasSuffix(wooSlug) && appSlug.count > wooSlug.count {
                            // Zusätzliche Prüfung, um false positives zu vermeiden, z.B. "sofas" und "kinder-sofas"
                            // Wenn appSlug "etwas-sofas" ist und wooSlug "sofas", muss das "etwas-" dem Hauptkategorie-Slug ähneln.
                            // Fürs Erste ist hasSuffix ein guter Kompromiss.
                            return true
                        }
                        
                        // Ggf. weitere Logik, wenn Slugs stark abweichen.
                        // Für den Moment verlassen wir uns auf direkten Match oder Suffix-Match.
                        return false
                    }
                    
                    if matchedWooCategory != nil {
                        print("SubCategoryViewModel: Matched AppSubItem '\(appSubItem.label)' (AppSlug: \(appSubItem.linkSlug)) with WooCommerce Category '\(matchedWooCategory!.name)' (WooSlug: \(matchedWooCategory!.slug), ID: \(matchedWooCategory!.id))")
                    } else {
                        print("SubCategoryViewModel: WARNING - No WooCommerce category found for AppSubItem '\(appSubItem.label)' (AppSlug: '\(appSubItem.linkSlug)') under parent '\(appNavigationItem.label)'. This subcategory will not have a WooCommerce ID for navigation.")
                    }
                    
                    tempDisplayableCategories.append(
                        DisplayableSubCategory(
                            id: appSubItem.linkSlug, // Verwende linkSlug als eindeutige ID für die ForEach-Schleife
                            label: appSubItem.label,
                            iconName: appSubItem.iconFilename,
                            wooCommerceCategoryID: matchedWooCategory?.id,
                            wooCommerceCategorySlug: matchedWooCategory?.slug
                        )
                    )
                }
                
                self.displayableSubCategories = tempDisplayableCategories
                print("SubCategoryViewModel: Successfully processed \(self.displayableSubCategories.count) displayable subcategories for '\(appNavigationItem.label)'.")

            } catch let error as WooCommerceAPIError {
                self.errorMessage = "Fehler beim Laden der Unterkategorien: \(error.localizedDescription)"
                print("SubCategoryViewModel Error (WooCommerceAPIError) for '\(appNavigationItem.label)': \(error)")
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
                print("SubCategoryViewModel Error (Unknown) for '\(appNavigationItem.label)': \(error)")
            }
            self.isLoading = false
        }
    }
}