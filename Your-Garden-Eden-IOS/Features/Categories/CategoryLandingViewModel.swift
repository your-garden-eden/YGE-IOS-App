// DATEI: CategoryLandingViewModel.swift
// PFAD: Features/Categories/ViewModels/CategoryLandingViewModel.swift
// VERSION: 1.0 (FINAL)

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
    }
    
    func loadContent() async {
        guard viewState == .loading else { return }
        logger.info("Lade Inhalt für Kategorie-Landing-Page '\(category.name)' (ID: \(category.id)).")

        do {
            let fetchedSubCategories = try await api.fetchCategories(parent: category.id)
            
            if !fetchedSubCategories.isEmpty {
                self.subCategories = fetchedSubCategories
                self.viewState = .showSubCategories
            } else {
                var params = ProductFilterParameters(); params.categoryId = category.id
                let productResponse = try await api.fetchProducts(params: params, perPage: 1)
                self.viewState = productResponse.products.isEmpty ? .empty : .showProducts
            }
        } catch {
            self.viewState = .error("Inhalte konnten nicht geladen werden.")
            logger.error("Fehler beim Laden des Inhalts für Kategorie \(category.id): \(error.localizedDescription)")
        }
    }
}
