// DATEI: ProductFilterState.swift
// PFAD: Services/App/ProductFilterState.swift
// VERSION: FINAL - Alle Operationen integriert.

import SwiftUI

@MainActor
class ProductFilterState: ObservableObject {

    @Published var selectedSortOption: ProductSortOption = .newest
    let absolutePriceRange: ClosedRange<Double> = 0...2000
    @Published var minPrice: Double
    @Published var maxPrice: Double
    @Published var showOnlyAvailable: Bool = true
    @Published var selectedProductType: ProductTypeFilterOption = .all
    
    struct FilterableAttribute: Identifiable, Hashable {
        let definition: WooCommerceAttributeDefinition
        let terms: [WooCommerceAttributeTerm]
        var id: Int { definition.id }
    }
    
    @Published var availableAttributes: [FilterableAttribute] = []
    @Published var selectedAttributeTerms: [String: Set<String>] = [:]
    @Published var attributeLoadingState: AttributeLoadingState = .idle

    private let logger = LogSentinel.shared

    var isPristine: Bool {
        selectedSortOption == .newest &&
        minPrice == absolutePriceRange.lowerBound &&
        maxPrice == absolutePriceRange.upperBound &&
        showOnlyAvailable == true &&
        selectedProductType == .all &&
        selectedAttributeTerms.isEmpty
    }

    init() {
        self.minPrice = absolutePriceRange.lowerBound
        self.maxPrice = absolutePriceRange.upperBound
    }

    func reset() {
        selectedSortOption = .newest
        minPrice = absolutePriceRange.lowerBound
        maxPrice = absolutePriceRange.upperBound
        showOnlyAvailable = true
        selectedProductType = .all
        selectedAttributeTerms.removeAll()
        logger.info("Filterzustand wurde zurückgesetzt.")
    }
    
    func loadAvailableAttributes() async {
        switch attributeLoadingState {
        case .loading, .success:
            return
        case .idle, .failed:
            break
        }
        
        self.attributeLoadingState = .loading
        logger.info("Laden der verfügbaren Filter-Attribute gestartet.")
        
        do {
            let apiManager = WooCommerceAPIManager.shared
            let definitions = try await apiManager.fetchAttributeDefinitions()
            
            let allowedAttributeSlugs: Set<String> = ["pa_farbe", "pa_material"]
            logger.info("Filter-Fokus aktiv. Erlaube nur Attribute: \(allowedAttributeSlugs).")

            let filteredDefinitions = definitions.filter { allowedAttributeSlugs.contains($0.slug) }
            logger.info("\(definitions.count) Attribute vom Server empfangen, \(filteredDefinitions.count) nach Fokus-Filterung übrig.")

            let results: [FilterableAttribute] = try await withThrowingTaskGroup(of: FilterableAttribute?.self, returning: [FilterableAttribute].self) { group in
                for definition in filteredDefinitions {
                    guard definition.type == "select" else { continue }
                    
                    group.addTask {
                        do {
                            let terms = try await apiManager.fetchAttributeTerms(for: definition.id)
                            return FilterableAttribute(definition: definition, terms: terms)
                        } catch {
                            await self.logger.error("Fehler beim Laden der Terms für Attribut \(definition.name): \(error)")
                            return nil
                        }
                    }
                }
                
                var collected: [FilterableAttribute] = []
                for try await result in group {
                    if let attribute = result, !attribute.terms.isEmpty {
                        collected.append(attribute)
                    }
                }
                return collected
            }
            
            self.availableAttributes = results.sorted { $0.definition.name < $1.definition.name }
            self.attributeLoadingState = .success
            logger.info("Verfügbare Filter-Attribute erfolgreich geladen und verarbeitet.")
            
        } catch {
            logger.error("Schwerwiegender Fehler beim Laden der Attribute: \(error.localizedDescription)")
            self.attributeLoadingState = .failed(error)
        }
    }
    
    func toggleSelection(forAttributeSlug attributeSlug: String, termSlug: String) {
        var selections = selectedAttributeTerms[attributeSlug] ?? Set<String>()
        
        if selections.contains(termSlug) {
            selections.remove(termSlug)
        } else {
            selections.insert(termSlug)
        }
        
        if selections.isEmpty {
            selectedAttributeTerms.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributeTerms[attributeSlug] = selections
        }
        logger.debug("Filterauswahl aktualisiert: \(selectedAttributeTerms)")
    }
    
    func isTermSelected(forAttributeSlug attributeSlug: String, termSlug: String) -> Bool {
        return selectedAttributeTerms[attributeSlug]?.contains(termSlug) ?? false
    }
}
