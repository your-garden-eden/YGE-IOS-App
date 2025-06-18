// DATEI: ProductOptionsViewModel.swift
// PFAD: Features/Products/ViewModels/Options/ProductOptionsViewModel.swift
// ZWECK: Verwaltet die komplexe Logik zur Auswahl von Produktvariationen,
//        berechnet die Verfügbarkeit und den Preis in Echtzeit und interagiert mit dem Warenkorb-Manager.

import SwiftUI
import Combine

@MainActor
final class ProductOptionsViewModel: ObservableObject {
    
    // MARK: - Eingangs-Eigenschaften
    let product: WooCommerceProduct
    private let purchasableVariations: [WooCommerceProductVariation]
    private let cartManager = CartAPIManager.shared

    // MARK: - Veröffentlichter Zustand für die View
    @Published var selectedAttributes: [String: String] = [:]
    @Published private(set) var availability: [String: Set<String>] = [:]
    @Published var addToCartError: String?
    @Published var quantity: Int = 1
    
    let displayableAttributes: [DisplayableAttribute]

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Berechnete Eigenschaften
    
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
            return PriceFormatter.FormattedPrice(display: "Ab \(range)", strikethrough: nil)
        }
        return PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price)
    }
    
    var stockStatusMessage: (text: String, color: Color) {
        if selectedAttributes.count < displayableAttributes.count {
            return ("Bitte alle Optionen wählen", AppTheme.Colors.textMuted)
        }
        if selectedVariation != nil {
             return ("Auf Lager", AppTheme.Colors.success)
        } else {
             return ("Diese Kombination ist nicht verfügbar", AppTheme.Colors.error)
        }
    }

    var isAddToCartDisabled: Bool {
        cartManager.state.isLoading || selectedVariation == nil
    }

    // MARK: - Initialisierung
    
    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.purchasableVariations = variations.filter { $0.isPurchasable && $0.isInStock }
        
        self.displayableAttributes = product.safeAttributes.compactMap { attr in
            guard attr.variation else { return nil }
            let options = attr.options.map { DisplayableAttribute.Option(name: $0, slug: $0.slugify()) }
            return DisplayableAttribute(name: attr.name, slug: attr.name.slugify(), options: options)
        }
        
        setupBindings()
        updateAvailability()
    }
    
    // MARK: - Benutzer-Aktionen
    
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

    // MARK: - Private Logik
    
    private func setupBindings() {
        $selectedAttributes
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateAvailability() }
            .store(in: &cancellables)
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

// MARK: - Displayable Attribute Helper Struct
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
