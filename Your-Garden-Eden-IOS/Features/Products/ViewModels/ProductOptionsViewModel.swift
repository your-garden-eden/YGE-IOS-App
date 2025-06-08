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
    
    private let currencySymbol: String
    
    // MARK: - Initializer
    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.variations = variations
        self.currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"
        self.currentImage = product.images.first
        
        // Initialen Zustand setzen, als ob keine Variation gewählt wäre
        updateState()
    }
    
    // MARK: - Public User Intents
    
    // Diese Funktion muss nicht mehr async sein.
    func select(attributeSlug: String, optionSlug: String) {
        if selectedAttributes[attributeSlug] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributes[attributeSlug] = optionSlug
        }
        // Direkter, synchroner Aufruf.
        updateState()
    }
    
    func addToCart() {
        guard let variation = selectedVariation else { return }
        CartManager.shared.addToCart(product: product, variation: variation, quantity: quantity)
    }
    
    // MARK: - Core Logic
    
    func availableOptionSlugs(for attribute: WooCommerceAttribute) -> Set<String> {
        // Dieser Code ist synchron und bleibt unverändert
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

    // --- KORREKTUR HIER ---
    // Die Funktion ist jetzt wieder synchron, da sie keine await-Aufrufe mehr hat.
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
            // Der Preis einer Variation ist immer ein einfacher String.
            displayPrice = "\(currencySymbol)\(variation.price)"
            isAddToCartDisabled = variation.stockStatus != .instock
        } else {
            currentImage = product.images.first
            
            // Wir verwenden die neue, synchrone Funktion.
            let formattedPrice = PriceFormatter.formatPriceString(
                from: product.priceHtml,
                fallbackPrice: product.price,
                currencySymbol: self.currencySymbol
            )
            displayPrice = formattedPrice.display
            
            isAddToCartDisabled = true
        }
    }
}
