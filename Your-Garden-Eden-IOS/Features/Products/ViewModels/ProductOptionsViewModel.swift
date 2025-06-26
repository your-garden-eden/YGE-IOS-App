
// DATEI: ProductOptionsViewModel.swift
// PFAD: Features/Products/ViewModels/Options/ProductOptionsViewModel.swift
// VERSION: 1.2 (SYNCHRONISIERT)
// STATUS: Einsatzbereit.

import SwiftUI
import Combine

@MainActor
final class ProductOptionsViewModel: ObservableObject {
    
    let product: WooCommerceProduct
    private let purchasableVariations: [WooCommerceProductVariation]
    private let cartManager = CartAPIManager.shared

    @Published var selectedAttributes: [String: String] = [:]
    @Published private(set) var availability: [String: Set<String>] = [:]
    @Published var addToCartError: String?
    @Published var quantity: Int = 1
    
    let displayableAttributes: [DisplayableAttribute]

    private var cancellables = Set<AnyCancellable>()
    private let logger = LogSentinel.shared
    
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

    // --- KORRIGIERTE PREISLOGIK ---
    var displayPrice: PriceFormatter.FormattedPrice {
        if let variation = selectedVariation {
            // KORREKTUR: Variationen werden mit einer dedizierten Funktion im PriceFormatter formatiert.
            // Sie haben kein 'price_html'.
            return PriceFormatter.formatVariationPrice(variation)
        }
        // KORREKTUR: Für das Hauptprodukt wird die neue, robuste formatDisplayPrice-Funktion verwendet.
        return PriceFormatter.formatDisplayPrice(for: product)
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
    
    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        self.product = product
        self.purchasableVariations = variations.filter { $0.isPurchasable && $0.isInStock }
        
        self.displayableAttributes = product.safeAttributes.compactMap { (attr: WooCommerceAttribute) -> DisplayableAttribute? in
            guard attr.variation, let attrName = attr.name else { return nil }
            let options = attr.options.map { DisplayableAttribute.Option(name: $0, slug: $0.slugify()) }
            return DisplayableAttribute(name: attrName, slug: attrName.slugify(), options: options)
        }
        
        setupBindings()
        updateAvailability()
        logger.info("ProductOptionsViewModel initialisiert für Produkt \(product.id) mit \(self.purchasableVariations.count) kaufbaren Variationen.")
    }
    
    func select(attributeSlug: String, optionSlug: String) {
        addToCartError = nil
        if selectedAttributes[attributeSlug] == optionSlug {
            selectedAttributes.removeValue(forKey: attributeSlug)
            logger.debug("Attribut '\(attributeSlug)' abgewählt.")
        } else {
            selectedAttributes[attributeSlug] = optionSlug
            logger.debug("Attribut '\(attributeSlug)' ausgewählt: '\(optionSlug)'.")
        }
    }
    
    func handleAddToCart() async {
        guard let variation = selectedVariation else {
            self.addToCartError = "Bitte wähle eine gültige Produktkombination."
            logger.warning("Benutzer versuchte, eine ungültige/unvollständige Variation zum Warenkorb hinzuzufügen.")
            return
        }
        addToCartError = nil
        logger.info("Füge gewählte Variation \(variation.id) von Produkt \(product.id) zum Warenkorb hinzu.")
        await cartManager.addItem(productId: product.id, quantity: quantity, variationId: variation.id)
    }
    
    private func setupBindings() {
        $selectedAttributes
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selections in
                self?.updateAvailability()
                self?.logger.debug("Auswahl geändert. Neue Auswahl: \(selections). Verfügbarkeit wird neu berechnet.")
            }
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

