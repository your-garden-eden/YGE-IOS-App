// Path: Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductOptionsViewModel.swift
// VERSION 4.2 (FINAL - Connects to Cart)

import SwiftUI
import Combine

@MainActor
final class ProductOptionsViewModel: ObservableObject {
    
    // MARK: - Input Properties
    let product: WooCommerceProduct
    private let purchasableVariations: [WooCommerceProductVariation]
    private let cartManager = CartAPIManager.shared

    // MARK: - Published State for the View
    @Published var selectedAttributes: [String: String] = [:]
    @Published private(set) var availability: [String: Set<String>] = [:]
    @Published var addToCartError: String?
    @Published var quantity: Int = 1

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    
    var selectedVariation: WooCommerceProductVariation? {
        guard selectedAttributes.count == self.displayableAttributes.count else { return nil }
        return purchasableVariations.first { variation in
            selectedAttributes.allSatisfy { (attrSlug, optionSlug) in
                variation.safeAttributes.contains { $0.name?.slugify() == attrSlug && $0.option?.slugify() == optionSlug }
            }
        }
    }
    
    var currentImage: WooCommerceImage? {
        selectedVariation?.image ?? product.safeImages.first
    }

    var displayPrice: PriceFormatter.FormattedPrice {
        if let variation = selectedVariation {
            return PriceFormatter.formatPriceString(from: variation.price_html, fallbackPrice: variation.price)
        }
        if let range = PriceFormatter.calculatePriceRange(from: self.purchasableVariations) {
            return PriceFormatter.FormattedPrice(display: range, strikethrough: nil)
        }
        return PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price)
    }
    
    var stockStatusMessage: (text: String, color: Color) {
        if selectedAttributes.count != displayableAttributes.count {
            return ("Bitte alle Optionen wählen", AppColors.textMuted)
        }
        if selectedVariation != nil {
             return ("Auf Lager", AppColors.success)
        } else {
             return ("Diese Kombination ist nicht verfügbar", AppColors.error)
        }
    }

    var isAddToCartDisabled: Bool {
        cartManager.state.isLoading || selectedVariation == nil
    }
    
    let displayableAttributes: [DisplayableAttribute]

    // MARK: - Initializer & Setup
    
    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.purchasableVariations = variations.filter { $0.isPurchasable && $0.isInStock }
        
        self.displayableAttributes = product.safeAttributes.compactMap { attr in
            guard attr.variation else { return nil }
            let options = attr.options.map { DisplayableAttribute.Option(name: $0, slug: $0.slugify()) }
            return DisplayableAttribute(name: attr.name, slug: attr.name.slugify(), options: options)
        }
        
        $selectedAttributes
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateState() }
            .store(in: &cancellables)
        
        print("📦 ProductOptionsViewModel initialized for '\(product.name)' with \(self.purchasableVariations.count) purchasable variations.")
        updateState()
    }
    
    // MARK: - User Actions
    
    func select(attributeSlug: String, optionSlug: String) {
        addToCartError = nil
        if selectedAttributes[attributeSlug] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributes[attributeSlug] = optionSlug
        }
    }
    
    // **DIESE FUNKTION IST DER SCHLÜSSEL**
    func handleAddToCart() async {
        guard let variation = selectedVariation else {
            self.addToCartError = "Bitte wähle eine gültige Produktkombination."
            return
        }
        addToCartError = nil
        // Ruft den zentralen Manager auf, um das Produkt hinzuzufügen.
        await cartManager.addItem(productId: product.id, quantity: quantity, variationId: variation.id)
    }

    // MARK: - Private Logic
    
    private func updateState() {
        updateAvailability()
    }
    
    private func updateAvailability() {
        var newAvailability: [String: Set<String>] = [:]
        for currentAttribute in displayableAttributes {
            var availableOptionSlugs = Set<String>()
            let otherSelections = selectedAttributes.filter { $0.key != currentAttribute.slug }
            
            let possibleVariations = self.purchasableVariations.filter { variation in
                otherSelections.allSatisfy { (selectedAttrSlug, selectedOptionSlug) in
                    variation.safeAttributes.contains { $0.name?.slugify() == selectedAttrSlug && $0.option?.slugify() == selectedOptionSlug }
                }
            }
            
            for variation in possibleVariations {
                if let attrForThisVariation = variation.safeAttributes.first(where: { ($0.name ?? "").slugify() == currentAttribute.slug }) {
                    if let optionValue = attrForThisVariation.option {
                        availableOptionSlugs.insert(optionValue.slugify())
                    }
                }
            }
            newAvailability[currentAttribute.slug] = availableOptionSlugs
        }
        self.availability = newAvailability
    }
}

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
