// Dateiname: ProductOptionsViewModel.swift

import SwiftUI
import Combine

@MainActor
class ProductOptionsViewModel: ObservableObject {
    
    let product: WooCommerceProduct
    let variations: [WooCommerceProductVariation]
    
    @Published var selectedAttributes: [String: String] = [:] {
        didSet { updateState() }
    }
    @Published private(set) var availability: [String: Set<String>] = [:]
    @Published private(set) var selectedVariation: WooCommerceProductVariation?
    @Published var quantity: Int = 1
    @Published private(set) var isAddingToCart: Bool = false
    @Published private(set) var addToCartError: String?

    var displayableAttributes: [DisplayableAttribute] {
        product.attributes.compactMap { productAttribute in
            guard productAttribute.variation else { return nil }
            let options = productAttribute.options.map { optionName in
                let optionSlug = optionName.lowercased().replacingOccurrences(of: " ", with: "-")
                return DisplayableAttribute.Option(name: optionName, slug: optionSlug)
            }
            return DisplayableAttribute(name: productAttribute.name, options: options)
        }
    }
    
    var currentImage: WooCommerceImage? { selectedVariation?.image ?? product.images.first }
    var displayPrice: String { (selectedVariation?.priceHtml ?? product.priceHtml ?? product.price).strippingHTML() }
    var isAddToCartDisabled: Bool { product.type == .variable && (selectedAttributes.count != displayableAttributes.count || selectedVariation == nil) }

    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.variations = variations
        print("📦 ProductOptionsViewModel initialized for product '\(product.name)' with \(variations.count) variations.")
        updateState()
    }
    
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
    
    func handleAddToCart() async {
        guard !isAddingToCart, let variation = selectedVariation else { return }
        
        isAddingToCart = true
        addToCartError = nil
        
        // KORREKTUR: Kein do-try-catch mehr nötig. Die Funktion wirft keine Fehler.
        await CartAPIManager.shared.addItem(
            productId: product.id,
            quantity: quantity,
            variationId: variation.id
        )
        
        // Wir können hier direkt auf die errorMessage Eigenschaft des Singletons schauen,
        // um zu wissen, ob ein Fehler aufgetreten ist.
        if let cartError = CartAPIManager.shared.errorMessage {
            self.addToCartError = cartError
            print("🔴 ProductOptionsViewModel: Failed to add item to cart: \(cartError)")
        }
        
        isAddingToCart = false
    }

    func updateState() {
        var newAvailability: [String: Set<String>] = [:]
        for attribute in displayableAttributes {
            var availableOptions = Set<String>()
            let otherSelections = selectedAttributes.filter { $0.key != attribute.name }
            let possibleVariations = variations.filter { variation in
                otherSelections.allSatisfy { (selectedName, selectedOptionSlug) in
                    variation.attributes.contains { $0.name == selectedName && $0.optionAsSlug() == selectedOptionSlug }
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
        let matchingVariation = variations.first { variation in
            guard variation.attributes.count == selectedAttributes.count else { return false }
            return selectedAttributes.allSatisfy { (selectedName, selectedOptionSlug) in
                variation.attributes.contains { $0.name == selectedName && $0.optionAsSlug() == selectedOptionSlug }
            }
        }
        if self.selectedVariation?.id != matchingVariation?.id {
            self.selectedVariation = matchingVariation
            print("🔄 Selected variation updated to: \(matchingVariation?.id ?? -1)")
        }
    }
}

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
