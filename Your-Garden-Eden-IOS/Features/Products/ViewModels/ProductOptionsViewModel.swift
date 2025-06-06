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
    @Published var displayPrice: String = "..." // Beginnt mit einem Platzhalter
    @Published var isAddToCartDisabled: Bool = true
    @Published var quantity: Int = 1
    
    private let currencySymbol: String
    
    // MARK: - Initializer
    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.variations = variations
        self.currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"
        self.currentImage = product.images.first
    }
    
    // MARK: - Public User Intents
    
    /// Diese Funktion wird jetzt asynchron, da sie `updateState` aufruft.
    func select(attributeSlug: String, optionSlug: String) async {
        if selectedAttributes[attributeSlug] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributes[attributeSlug] = optionSlug
        }
        await updateState()
    }
    
    func addToCart() {
        guard let variation = selectedVariation else { return }
        CartManager.shared.addToCart(product: product, variation: variation, quantity: quantity)
    }
    
    // MARK: - Core Logic
    
    func availableOptionSlugs(for attribute: WooCommerceAttribute) -> Set<String> {
        // ... (Dieser Code ist synchron und bleibt unverändert)
        guard let attributeSlug = attribute.slug else { return [] }
        let otherSelections = selectedAttributes.filter { $0.key != attributeSlug }
        let potentialVariations = variations.filter { variation in
            if otherSelections.isEmpty { return true }
            return otherSelections.allSatisfy { (key, value) in
                variation.attributes.contains { $0.name == key && $0.optionAsSlug() == value }
            }
        }
        let availableSlugs = potentialVariations.flatMap { $0.attributes }.filter { $0.name == attributeSlug }.map { $0.optionAsSlug() }
        return Set(availableSlugs)
    }

    /// Diese Funktion muss jetzt asynchron sein, da sie den asynchronen PriceFormatter aufruft.
    func updateState() async {
        let matchingVariation = variations.first { variation in
            guard variation.attributes.count == selectedAttributes.count else { return false }
            return selectedAttributes.allSatisfy { (key, value) in
                variation.attributes.contains { $0.name == key && $0.optionAsSlug() == value }
            }
        }
        
        self.selectedVariation = matchingVariation
        
        if let variation = matchingVariation {
            currentImage = variation.image ?? product.images.first
            displayPrice = "\(currencySymbol)\(variation.price)"
            isAddToCartDisabled = variation.stockStatus != .instock
        } else {
            currentImage = product.images.first
            // Der Aufruf an die async-Funktion muss hier mit 'await' erfolgen.
            displayPrice = await PriceFormatter.formatPrice(from: product.priceHtml) ?? "\(currencySymbol)\(product.price)"
            isAddToCartDisabled = true
        }
    }
}
