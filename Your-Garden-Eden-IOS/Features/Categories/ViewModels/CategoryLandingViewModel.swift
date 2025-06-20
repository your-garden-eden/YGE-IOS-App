// DATEI: CategoryLandingViewModel.swift
// PFAD: Features/Categories/ViewModels/CategoryLandingViewModel.swift
// VERSION: FINAL - Alle Operationen integriert.

import Foundation

@MainActor
class CategoryLandingViewModel: ObservableObject {
    
    @Published var subCategories: [WooCommerceCategory] = []
    @Published var viewState: ViewState = .loading
    
    private let category: WooCommerceCategory
    private let api = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared
    
    init(category: WooCommerceCategory) {
        self.category = category
        logger.info("CategoryLandingViewModel initialisiert für Kategorie '\(category.name)' (ID: \(category.id)).")
    }
    
    func loadContent() async {
        guard viewState == .loading else { return }
        logger.info("Lade Inhalt für Kategorie-Landing-Page \(category.id)...")

        do {
            let fetchedSubCategories = try await api.fetchCategories(parent: category.id)
            
            if !fetchedSubCategories.isEmpty {
                logger.info("\(fetchedSubCategories.count) Unterkategorien gefunden für Kategorie \(category.id). Zeige Unterkategorien-Liste.")
                self.subCategories = fetchedSubCategories.sorted { ($0.menu_order ?? 999) < ($1.menu_order ?? 999) }
                self.viewState = .showSubCategories
            } else {
                logger.info("Keine Unterkategorien für Kategorie \(category.id) gefunden. Prüfe auf Produkte...")
                var params = ProductFilterParameters()
                params.categoryId = category.id
                
                let productResponse = try await api.fetchProducts(params: params, perPage: 1)
                
                if productResponse.products.isEmpty {
                    logger.notice("Keine Produkte in Kategorie \(category.id) gefunden. Zeige 'Leer'-Zustand.")
                    self.viewState = .empty
                } else {
                    logger.info("Produkte in Kategorie \(category.id) gefunden. Zeige Produktliste an.")
                    self.viewState = .showProducts
                }
            }
        } catch let apiError as WooCommerceAPIError {
            self.viewState = .error(apiError.localizedDescriptionForUser)
            logger.error("Fehler beim Laden des Inhalts für Kategorie \(category.id): \(apiError.localizedDescription)")
        } catch {
            self.viewState = .error("Ein unerwarteter Fehler ist aufgetreten.")
            logger.error("Unerwarteter Fehler beim Laden des Inhalts für Kategorie \(category.id): \(error.localizedDescription)")
        }
    }
}
