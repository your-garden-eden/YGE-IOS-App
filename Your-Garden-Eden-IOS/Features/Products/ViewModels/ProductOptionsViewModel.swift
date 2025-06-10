// Features/Products/ViewModels/ProductOptionsViewModel.swift

import SwiftUI
import Combine

// NEUE, SAUBERE DATENSTRUKTUREN FÜR DIE VIEW
// Diese halten sowohl den Anzeigenamen als auch den ECHTEN Slug von der API.
struct DisplayableAttribute {
    let name: String
    let slug: String
    var options: [DisplayableOption]
}

struct DisplayableOption: Hashable, Identifiable {
    var id: String { slug }
    let name: String
    let slug: String
}

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
    
    func select(attributeSlug: String, optionSlug: String) {
        if selectedAttributes[attributeSlug] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributes[attributeSlug] = optionSlug
        }
        updateState()
    }
    
    // NEUE addToCart-Logik, die den CartAPIManager verwendet
    @discardableResult
    func handleAddToCart() async -> Bool {
        guard let variation = selectedVariation else {
            self.addToCartError = "Bitte wählen Sie eine gültige Option."
            return false
        }

        isAddingToCart = true
        addToCartError = nil
        
        do {
            // Der Aufruf des KORREKTEN Managers
            try await CartAPIManager.shared.addItem(
                productId: variation.id,
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

    func availableOptionSlugs(for attribute: DisplayableAttribute) -> Set<String> {
        let otherSelections = selectedAttributes.filter { $0.key != attribute.slug }
        let potentialVariations = variations.filter { variation in
            if otherSelections.isEmpty { return true }
            return otherSelections.allSatisfy { (key, value) in
                variation.attributes.contains { $0.name == key && $0.optionAsSlug() == value }
            }
        }
        let availableSlugs = potentialVariations.flatMap { $0.attributes }.filter { $0.name == attribute.name }.map { $0.optionAsSlug() }
        return Set(availableSlugs)
    }

    func updateState() {
        let matchingVariation = variations.first { variation in
            guard variation.attributes.count == selectedAttributes.count else { return false }
            
            return selectedAttributes.allSatisfy { (key, value) in
                variation.attributes.contains { $0.name == key && $0.optionAsSlug() == value }
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
    
    private func calculatePriceRange() -> String {
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
