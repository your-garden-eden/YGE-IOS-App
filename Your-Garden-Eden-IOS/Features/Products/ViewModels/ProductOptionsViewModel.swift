//
//  ProductOptionsViewModel.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import SwiftUI
import Combine

@MainActor
class ProductOptionsViewModel: ObservableObject {
    
    // MARK: - Input Properties
    let product: WooCommerceProduct
    let variations: [WooCommerceProductVariation]
    
    // MARK: - Published State for UI
    
    // KORREKTUR: Key ist der Attribut-NAME (z.B. "Farbe"), Value ist der ausgewählte Options-SLUG (z.B. "rot").
    @Published var selectedAttributes: [String: String] = [:] {
        didSet { updateState() }
    }
    
    // KORREKTUR: Key ist der Attribut-NAME, Value ist das Set der verfügbaren Options-SLUGS.
    @Published private(set) var availability: [String: Set<String>] = [:]

    @Published private(set) var selectedVariation: WooCommerceProductVariation?
    @Published var quantity: Int = 1
    @Published private(set) var isAddingToCart: Bool = false
    @Published private(set) var addToCartError: String?

    // MARK: - Computed Properties for Views
    
    /// **KOMPLETT NEUE LOGIK**
    /// Erstellt die anzeigbaren Attribute basierend auf den Attributen des Hauptprodukts.
    var displayableAttributes: [DisplayableAttribute] {
        product.attributes.compactMap { productAttribute in
            guard productAttribute.variation else { return nil }
            
            let options = productAttribute.options.map { optionName in
                // Wir erstellen einen konsistenten Slug aus dem Options-Namen.
                let optionSlug = optionName.lowercased().replacingOccurrences(of: " ", with: "-")
                return DisplayableAttribute.Option(name: optionName, slug: optionSlug)
            }
            return DisplayableAttribute(name: productAttribute.name, options: options)
        }
    }
    
    var currentImage: WooCommerceImage? {
        selectedVariation?.image ?? product.images.first
    }
    
    var displayPrice: String {
        (selectedVariation?.priceHtml ?? product.priceHtml ?? product.price).strippingHTML()
    }
    
    var isAddToCartDisabled: Bool {
        // Deaktiviert, wenn es ein variables Produkt ist und nicht alle Attribute ausgewählt wurden.
        // ODER wenn keine gültige Variation für die Auswahl gefunden wurde.
        product.type == .variable && (selectedAttributes.count != displayableAttributes.count || selectedVariation == nil)
    }

    // MARK: - Initializer
    
    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.variations = variations
        print("📦 ProductOptionsViewModel initialized for product '\(product.name)' with \(variations.count) variations.")
        updateState()
    }
    
    // MARK: - Public Methods for View
    
    func availableOptionSlugs(for attribute: DisplayableAttribute) -> Set<String> {
        return availability[attribute.name] ?? []
    }
    
    func select(attributeName: String, optionSlug: String?) {
        addToCartError = nil
        if selectedAttributes[attributeName] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeName)
        } else if let optionSlug = optionSlug {
            selectedAttributes[attributeName] = optionSlug
        }
    }
    
    func handleAddToCart() async -> Bool {
        guard !isAddingToCart, let variation = selectedVariation else { return false }
        
        isAddingToCart = true
        addToCartError = nil
        defer { isAddingToCart = false }

        do {
            try await CartAPIManager.shared.addItem(
                productId: product.id,
                quantity: quantity,
                variationId: variation.id
            )
            return true
        } catch {
            print("🔴 Failed to add item to cart: \(error.localizedDescription)")
            self.addToCartError = "Produkt konnte nicht hinzugefügt werden."
            return false
        }
    }

    // MARK: - State Calculation
    
    /// **KOMPLETT NEUE LOGIK**
    /// Berechnet den Zustand neu, basierend auf Attribut-Namen und den Slugs der Optionen.
    func updateState() {
        var newAvailability: [String: Set<String>] = [:]

        for attribute in displayableAttributes {
            var availableOptions = Set<String>()
            let otherSelections = selectedAttributes.filter { $0.key != attribute.name }

            let possibleVariations = variations.filter { variation in
                otherSelections.allSatisfy { (selectedName, selectedOptionSlug) in
                    variation.attributes.contains { variationAttr in
                        variationAttr.name == selectedName && variationAttr.optionAsSlug() == selectedOptionSlug
                    }
                }
            }
            
            for variation in possibleVariations {
                if let optionForCurrentAttribute = variation.attributes.first(where: { $0.name == attribute.name }) {
                    availableOptions.insert(optionForCurrentAttribute.optionAsSlug())
                }
            }
            newAvailability[attribute.name] = availableOptions
        }
        
        self.availability = newAvailability
        updateSelectedVariation()
    }
    
    private func updateSelectedVariation() {
        guard product.type == .variable else {
            self.selectedVariation = nil
            return
        }
        
        // Finde EINE Variation, die zu ALLEN ausgewählten Attributen passt.
        let matchingVariation = variations.first { variation in
            // Die Anzahl der Variation-Attribute muss der Anzahl der Auswahlen entsprechen.
            guard variation.attributes.count == selectedAttributes.count else { return false }
            
            // Jede Auswahl muss in den Attributen der Variation vorhanden sein.
            return selectedAttributes.allSatisfy { (selectedName, selectedOptionSlug) in
                variation.attributes.contains { variationAttr in
                    variationAttr.name == selectedName && variationAttr.optionAsSlug() == selectedOptionSlug
                }
            }
        }
        
        if self.selectedVariation?.id != matchingVariation?.id {
            self.selectedVariation = matchingVariation
            print("🔄 Selected variation updated to: \(matchingVariation?.id ?? -1)")
        }
    }
}

// Die Datenstruktur wurde vereinfacht, da der Slug nicht mehr auf Top-Level benötigt wird.
extension ProductOptionsViewModel {
    struct DisplayableAttribute: Identifiable, Hashable {
        var id: String { name }
        let name: String
        let options: [Option]
        
        struct Option: Identifiable, Hashable {
            var id: String { slug }
            let name: String
            let slug: String
        }
    }
}
