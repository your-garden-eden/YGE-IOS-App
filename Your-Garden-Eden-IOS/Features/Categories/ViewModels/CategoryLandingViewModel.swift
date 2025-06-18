// DATEI: CategoryLandingViewModel.swift
// PFAD: Features/Categories/ViewModels/CategoryLandingViewModel.swift
// ZWECK: Verwaltet den Zustand und die Geschäftslogik für eine Kategorie-Landing-Page.
//        Ermittelt, ob Unterkategorien oder direkt eine Produktliste angezeigt werden soll.

import Foundation

@MainActor
class CategoryLandingViewModel: ObservableObject {
    
    // MARK: - View State Definition
    
    /// Definiert die möglichen Zustände, in denen sich die zugehörige View befinden kann.
    enum ViewState: Equatable {
        case loading
        case showSubCategories
        case showProducts
        case error(String)
        case empty
    }
    
    // MARK: - Veröffentlichte Eigenschaften
    
    /// Hält die Liste der gefundenen Unterkategorien, die in der View angezeigt werden sollen.
    @Published var subCategories: [WooCommerceCategory] = []
    
    /// Steuert den aktuellen Zustand der View.
    @Published var viewState: ViewState = .loading
    
    // MARK: - Private Eigenschaften
    
    private let category: WooCommerceCategory
    private let api = WooCommerceAPIManager.shared
    
    // MARK: - Initialisierung
    
    init(category: WooCommerceCategory) {
        self.category = category
    }
    
    // MARK: - Öffentliche Methoden
    
    /// Lädt den Inhalt für die Kategorie-Landing-Page.
    /// Die Methode prüft zuerst auf Unterkategorien. Falls keine vorhanden sind,
    /// wird geprüft, ob Produkte in der Hauptkategorie existieren, um über die
    /// weitere Navigation zu entscheiden.
    func loadContent() async {
        // Verhindert unnötige Ladevorgänge, wenn der Zustand nicht mehr `.loading` ist.
        guard viewState == .loading else { return }

        do {
            // Schritt 1: Versuche, Unterkategorien zu laden, die dieser Kategorie untergeordnet sind.
            let fetchedSubCategories = try await api.fetchCategories(parent: category.id)
            
            if !fetchedSubCategories.isEmpty {
                // Erfolgreich Unterkategorien gefunden. Sortiere sie nach `menu_order`.
                self.subCategories = fetchedSubCategories.sorted { ($0.menu_order ?? 999) < ($1.menu_order ?? 999) }
                self.viewState = .showSubCategories
            } else {
                // Schritt 2: Keine Unterkategorien gefunden. Prüfe, ob Produkte existieren.
                // Es wird nur ein Produkt (`perPage: 1`) angefordert, um die Antwort zu beschleunigen.
                var params = ProductFilterParameters()
                params.categoryId = category.id
                
                let productResponse = try await api.fetchProducts(params: params, perPage: 1)
                
                if productResponse.products.isEmpty {
                    // Keine Produkte in dieser Kategorie gefunden.
                    self.viewState = .empty
                } else {
                    // Es gibt Produkte, die View kann zur Produktliste navigieren.
                    self.viewState = .showProducts
                }
            }
        } catch let apiError as WooCommerceAPIError {
            self.viewState = .error(apiError.localizedDescriptionForUser)
        } catch {
            self.viewState = .error("Ein unerwarteter Fehler ist aufgetreten.")
        }
    }
}
