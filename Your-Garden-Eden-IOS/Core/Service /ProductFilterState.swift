// DATEI: ProductFilterState.swift
// PFAD: Features/Products/Services/ProductFilterState.swift
// VERSION: 1.2 (SYNTAX KORRIGIERT)
// STATUS: Einsatzbereit.

import SwiftUI

public enum AttributeLoadingState: Equatable {
    case idle
    case loading
    case success
    case failed(String)
}

@MainActor
public class ProductFilterState: ObservableObject {
    
    public struct FilterableAttribute: Identifiable, Hashable, Equatable {
        let definition: WooCommerceAttributeDefinition
        let terms: [WooCommerceAttributeTerm]
        public var id: Int { definition.id }
    }
    
    @Published public var selectedSortOption: ProductSortOption = .newest
    @Published public var showOnlyAvailable: Bool = false
    @Published public var selectedProductType: ProductTypeFilterOption = .all
    @Published public var minPrice: Double = 0
    @Published public var maxPrice: Double = 5000
    @Published public var selectedAttributeTerms: [String: Set<String>] = [:]
    
    @Published public var availableAttributes: [FilterableAttribute] = []
    @Published public var attributeLoadingState: AttributeLoadingState = .idle
    
    private let apiManager = WooCommerceAPIManager.shared
    private let logger = LogSentinel.shared
    public let absolutePriceRange: ClosedRange<Double> = 0...5000
    
    public func loadAvailableAttributes() async {
        // ===================================================================
        // === BEGINN KORREKTUR #10                                        ===
        // ===================================================================
        // Ersetzt die fehlerhafte 'guard'-Bedingung durch eine korrekte Prüfung.
        
        switch attributeLoadingState {
        case .loading, .success:
            // Wenn bereits geladen wird oder erfolgreich geladen wurde, abbrechen.
            return
        case .idle, .failed:
            // In den Zuständen .idle oder .failed, den Ladevorgang starten.
            break
        }
        
        // ===================================================================
        // === ENDE KORREKTUR #10                                          ===
        // ===================================================================
        
        logger.info("Lade verfügbare Filter-Attribute...")
        self.attributeLoadingState = .loading
        
        do {
            let definitions = try await apiManager.fetchAttributeDefinitions()
            let filteredDefinitions = definitions.filter { $0.type == "select" }
            
            var results: [FilterableAttribute] = []
            try await withThrowingTaskGroup(of: FilterableAttribute?.self) { group in
                for definition in filteredDefinitions {
                    group.addTask {
                        if let terms = try? await self.apiManager.fetchAttributeTerms(for: definition.id), !terms.isEmpty {
                            return FilterableAttribute(definition: definition, terms: terms)
                        }
                        return nil
                    }
                }
                for try await result in group {
                    if let attribute = result { results.append(attribute) }
                }
            }
            self.availableAttributes = results.sorted { $0.definition.name < $1.definition.name }
            self.attributeLoadingState = .success
            logger.info("\(self.availableAttributes.count) Filter-Attribute erfolgreich geladen.")
            
        } catch {
            let errorMessage = "Filteroptionen konnten nicht geladen werden."
            self.attributeLoadingState = .failed(errorMessage)
            logger.error("Fehler beim Laden der Filter-Attribute: \(error.localizedDescription)")
        }
    }
    
    public func toggleSelection(forAttributeSlug attrSlug: String, termSlug: String) {
        if var selections = selectedAttributeTerms[attrSlug] {
            if selections.contains(termSlug) {
                selections.remove(termSlug)
            } else {
                selections.insert(termSlug)
            }
            selectedAttributeTerms[attrSlug] = selections.isEmpty ? nil : selections
        } else {
            selectedAttributeTerms[attrSlug] = [termSlug]
        }
    }
    
    public func isTermSelected(forAttributeSlug attrSlug: String, termSlug: String) -> Bool {
        return selectedAttributeTerms[attrSlug]?.contains(termSlug) ?? false
    }
    
    public func reset() {
        selectedSortOption = .newest
        showOnlyAvailable = false
        selectedProductType = .all
        minPrice = absolutePriceRange.lowerBound
        maxPrice = absolutePriceRange.upperBound
        selectedAttributeTerms.removeAll()
    }
}
