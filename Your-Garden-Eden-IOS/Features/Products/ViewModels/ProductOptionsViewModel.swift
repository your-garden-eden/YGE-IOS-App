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
    
    // MARK: - Aufbereitete Daten für die View
    // Dies ist die neue "Source of Truth" für die UI.
    private(set) var displayableAttributes: [DisplayableAttribute] = []
    
    private let currencySymbol: String
    private let allowedAttributeNames: Set<String> = ["Color", "Model"]

    // MARK: - Initializer (MIT DER KORREKTUR)
    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.variations = variations
        self.currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"
        self.currentImage = product.images.first
        
        // --- DIE KERNLOGIK ZUR DATENAUFBEREITUNG ---
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
    
    // ... der Rest des Codes bleibt strukturell gleich ...
    
    func select(attributeSlug: String, optionSlug: String) {
        if selectedAttributes[attributeSlug] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributes[attributeSlug] = optionSlug
        }
        updateState()
    }
    
    func addToCart() {
        guard let variation = selectedVariation else { return }
        CartManager.shared.addToCart(product: product, variation: variation, quantity: quantity)
    }
    
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
            // Die Anzahl der API-Attribute der Variation muss der Anzahl der User-Auswahlen entsprechen.
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
