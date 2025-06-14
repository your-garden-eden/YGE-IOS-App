// Path: Your-Garden-Eden-IOS/Features/Products/ProductOptionsViewModel.swift

import SwiftUI
import Combine

@MainActor
final class ProductOptionsViewModel: ObservableObject {
    
    let product: WooCommerceProduct
    private let variations: [WooCommerceProductVariation]
    private let cartManager = CartAPIManager.shared

    @Published var selectedAttributes: [String: String] = [:] {
        didSet { updateState() }
    }
    
    @Published private(set) var selectedVariation: WooCommerceProductVariation?
    @Published private(set) var availability: [String: Set<String>] = [:]
    @Published var addToCartError: String?
    @Published var quantity: Int = 1

    var currentImage: WooCommerceImage? {
        selectedVariation?.image ?? product.images.first
    }

    var displayPrice: PriceFormatter.FormattedPrice {
        if let variation = selectedVariation {
            return PriceFormatter.formatPriceString(from: variation.priceHtml, fallbackPrice: variation.price, currencySymbol: "€")
        }
        return PriceFormatter.formatPriceString(from: product.priceHtml, fallbackPrice: product.price, currencySymbol: "€")
    }
    
    var stockStatusMessage: (text: String, color: Color) {
        let isSelectionComplete = selectedAttributes.count == displayableAttributes.count
        
        if !isSelectionComplete {
            return ("Bitte alle Optionen wählen", AppColors.textMuted)
        }
        
        if let variation = selectedVariation {
            return variation.isInStock ? ("Auf Lager", AppColors.success) : ("Nicht auf Lager", AppColors.error)
        }
        
        return ("Diese Kombination ist nicht verfügbar", AppColors.error)
    }

    var isAddToCartDisabled: Bool {
        selectedVariation == nil || selectedVariation?.isInStock == false
    }
    
    let displayableAttributes: [DisplayableAttribute]

    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.variations = variations
        
        self.displayableAttributes = product.attributes.compactMap { attr in
            guard attr.variation else { return nil }
            let options = attr.options.map { DisplayableAttribute.Option(name: $0, slug: $0.slugify()) }
            return DisplayableAttribute(name: attr.name, slug: attr.name.slugify(), options: options)
        }
        
        print("📦 ProductOptionsViewModel initialized for '\(product.name)'")
        updateState()
    }
    
    func select(attributeSlug: String, optionSlug: String) {
        addToCartError = nil
        if selectedAttributes[attributeSlug] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributes[attributeSlug] = optionSlug
        }
    }
    
    func handleAddToCart() async {
        guard let variation = selectedVariation else {
            self.addToCartError = "Bitte wähle eine gültige Produktkombination."
            return
        }
        
        addToCartError = nil
        await cartManager.addItem(productId: product.id, quantity: quantity, variationId: variation.id)
    }

    private func updateState() {
        updateSelectedVariation()
        updateAvailability()
    }
    
    private func updateAvailability() {
        var newAvailability: [String: Set<String>] = [:]
        
        for attribute in displayableAttributes {
            var availableOptions = Set<String>()
            let otherSelections = selectedAttributes.filter { $0.key != attribute.slug }
            
            let possibleVariations = variations.filter { variation in
                otherSelections.allSatisfy { (selectedSlug, selectedOptionSlug) in
                    variation.attributes.contains { $0.name.slugify() == selectedSlug && $0.option.slugify() == selectedOptionSlug }
                }
            }
            
            for variation in possibleVariations {
                if let optionForCurrentAttr = variation.attributes.first(where: { $0.name.slugify() == attribute.slug }) {
                    availableOptions.insert(optionForCurrentAttr.option.slugify())
                }
            }
            newAvailability[attribute.slug] = availableOptions
        }
        self.availability = newAvailability
    }
    
    private func updateSelectedVariation() {
        guard selectedAttributes.count == self.displayableAttributes.count else {
            if self.selectedVariation != nil { self.selectedVariation = nil }
            return
        }

        let matchingVariation = variations.first { variation in
            selectedAttributes.allSatisfy { (selectedSlug, selectedOptionSlug) in
                variation.attributes.contains { $0.name.slugify() == selectedSlug && $0.option.slugify() == selectedOptionSlug }
            }
        }
        
        if self.selectedVariation?.id != matchingVariation?.id {
            self.selectedVariation = matchingVariation
            print("🔄 Selected variation updated to: ID \(matchingVariation?.id ?? -1)")
        }
    }
}

// MARK: - Helper Structs
extension ProductOptionsViewModel {
    struct DisplayableAttribute: Identifiable {
        var id: String { slug }
        let name: String
        let slug: String
        let options: [Option]
        struct Option: Identifiable {
            var id: String { slug }
            let name: String
            let slug: String
        }
    }
}
