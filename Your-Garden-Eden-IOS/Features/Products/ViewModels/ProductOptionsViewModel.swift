// Features/Products/ViewModels/ProductOptionsViewModel.swift

import SwiftUI
import Combine

@MainActor
class ProductOptionsViewModel: ObservableObject {
    // MARK: - Input Properties
    let product: WooCommerceProduct
    let variations: [WooCommerceProductVariation]
    
    // MARK: - Published State Properties
    @Published var selectedAttributes: [String: String] = [:]
    @Published var selectedVariation: WooCommerceProductVariation?
    @Published var currentImage: WooCommerceImage?
    @Published var displayPrice: String = "..."
    @Published var isAddToCartDisabled: Bool = true
    @Published var quantity: Int = 1
    
    // NEU: Zusätzliche Zustände für die UI
    @Published var isAddingToCart = false
    @Published var addToCartError: String?

    // MARK: - Aufbereitete Daten für die View
    private(set) var displayableAttributes: [DisplayableAttribute] = []
    
    private let currencySymbol: String
    private let allowedAttributeNames: Set<String> = ["Color", "Model"]

    // MARK: - Initializer
    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.variations = variations
        self.currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"
        self.currentImage = product.images.first
        
        prepareDisplayableAttributes()
    }
    
    // KORREKTUR: 'private' entfernt, damit die Funktion von außerhalb (z.B. der View) aufgerufen werden kann.
    private func prepareDisplayableAttributes() {
        // 1. Sammle alle einzigartigen Optionen (Name + Slug) aus ALLEN Variationen.
        var uniqueOptionsByAttributeName = [String: [String: String]]() // [Attribut-Name: [Options-Name: Options-Slug]]
        
        for variation in variations {
            for attribute in variation.attributes {
                if uniqueOptionsByAttributeName[attribute.name] == nil {
                    uniqueOptionsByAttributeName[attribute.name] = [:]
                }
                // Speichere den echten Slug für den Optionsnamen
                uniqueOptionsByAttributeName[attribute.name]?[attribute.option] = attribute.optionAsSlug()
            }
        }
        
        // 2. Baue die finale `displayableAttributes`-Liste auf.
        self.displayableAttributes = product.attributes
            .filter { allowedAttributeNames.contains($0.name) && !$0.options.isEmpty }
            .compactMap { attribute -> DisplayableAttribute? in
                guard let attributeSlug = attribute.slug,
                      let optionsMap = uniqueOptionsByAttributeName[attribute.name] else {
                    return nil
                }
                
                let displayOptions = attribute.options.compactMap { optionName -> DisplayableOption? in
                    guard let optionSlug = optionsMap[optionName] else {
                        // Diese Option existiert in keiner Variation, also überspringen.
                        return nil
                    }
                    return DisplayableOption(name: optionName, slug: optionSlug)
                }
                
                guard !displayOptions.isEmpty else { return nil }
                
                return DisplayableAttribute(name: attribute.name, slug: attributeSlug, options: displayOptions)
            }
    }
    
    // MARK: - User Actions
    
    func select(attributeSlug: String, optionSlug: String?) {
        // KORREKTUR: 'private' entfernt, da die View diese Funktion benötigt.
        if selectedAttributes[attributeSlug] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributes[attributeSlug] = optionSlug
        }
        updateState()
    }
    
    @discardableResult
    func handleAddToCart() async -> Bool {
        guard let variation = selectedVariation else {
            self.addToCartError = "Bitte wählen Sie eine gültige Option."
            return false
        }

        isAddingToCart = true
        addToCartError = nil
        
        do {
            try await CartAPIManager.shared.addItem(
                productId: variation.id, // Korrekt: ID der Variation verwenden
                quantity: self.quantity
            )
            isAddingToCart = false
            return true // Erfolg
        } catch {
            print("Fehler beim Hinzufügen zum Warenkorb: \(error.localizedDescription)")
            self.addToCartError = "Das Produkt konnte nicht zum Warenkorb hinzugefügt werden."
            isAddingToCart = false
            return false // Misserfolg
        }
    }
    
    // MARK: - State Update Logic

    // KORREKTUR: 'private' entfernt, damit die View darauf zugreifen kann, um verfügbare Optionen zu bestimmen.
    func availableOptionSlugs(for attribute: DisplayableAttribute) -> Set<String> {
        let otherSelections = selectedAttributes.filter { $0.key != attribute.slug }
        
        let potentialVariations = variations.filter { variation in
            // Wenn nichts anderes ausgewählt ist, sind alle Variationen potenziell.
            if otherSelections.isEmpty { return true }
            
            // Prüfe, ob die Variation alle anderen Auswahlen enthält.
            return otherSelections.allSatisfy { (key, value) in
                // ACHTUNG: Der Key ist der Attribut-Slug, nicht der Name. Muss angepasst werden, wenn deine Logik auf Namen basiert.
                // Angenommen, der Slug ist der Schlüssel in `selectedAttributes`.
                variation.attributes.contains { $0.slug == key && $0.optionAsSlug() == value }
            }
        }
        
        // Sammle alle verfügbaren Options-Slugs für das gegebene Attribut aus den potenziellen Variationen.
        let availableSlugs = potentialVariations.flatMap { $0.attributes }
                                                .filter { $0.slug == attribute.slug }
                                                .map { $0.optionAsSlug() }
        
        return Set(availableSlugs)
    }

    // KORREKTUR: 'private' entfernt, da die View diese Funktion im .task-Modifier aufruft.
    func updateState() {
        let allAttributesSelected = displayableAttributes.allSatisfy { selectedAttributes[$0.slug] != nil }

        var matchingVariation: WooCommerceProductVariation? = nil
        if allAttributesSelected {
            matchingVariation = variations.first { variation in
                guard variation.attributes.count == displayableAttributes.count else { return false }
                
                return selectedAttributes.allSatisfy { (key, value) in
                    variation.attributes.contains { $0.slug == key && $0.optionAsSlug() == value }
                }
            }
        }
        
        self.selectedVariation = matchingVariation
        
        if let variation = matchingVariation {
            currentImage = variation.image ?? product.images.first
            displayPrice = PriceFormatter.formatPrice(variation.price, currencySymbol: currencySymbol)
            isAddToCartDisabled = variation.stockStatus != .instock
        } else {
            currentImage = product.images.first
            displayPrice = calculatePriceRange()
            isAddToCartDisabled = true
        }
    }
    
    // KORREKTUR: 'private' entfernt. Auch wenn sie nur intern genutzt wird, ist es sicherer,
    // sie zugänglich zu machen, falls die Logik komplexer wird. Es schadet nicht.
    func calculatePriceRange() -> String {
        let prices = variations.compactMap { Double($0.price) }
        
        guard !prices.isEmpty, let minPrice = prices.min(), let maxPrice = prices.max() else {
            return PriceFormatter.formatPriceString(from: product.priceHtml, fallbackPrice: product.price, currencySymbol: self.currencySymbol).display
        }
        
        if minPrice == maxPrice {
            return "Ab \(PriceFormatter.formatPrice(String(minPrice), currencySymbol: currencySymbol))"
        } else {
            let formattedMin = PriceFormatter.formatPrice(String(minPrice), currencySymbol: currencySymbol)
            let formattedMax = PriceFormatter.formatPrice(String(maxPrice), currencySymbol: currencySymbol)
            return "\(formattedMin) – \(formattedMax)"
        }
    }
}
