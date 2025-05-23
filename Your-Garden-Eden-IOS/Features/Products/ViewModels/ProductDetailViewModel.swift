// Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductDetailViewModel.swift
import SwiftUI

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var product: WooCommerceProduct?
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var selectedAttributes: [String: String] = [:] // Key: Attribut-Slug (z.B. "pa_farbe"), Value: Options-Slug (z.B. "rot")
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var productSlugForCurrentData: String? { product?.slug }
    
    private let initialProductSlug: String // Der Slug, mit dem das VM initialisiert wurde
    private let initialProductData: WooCommerceProduct?

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        self.initialProductSlug = productSlug // Speichere den initialen Slug
        self.initialProductData = initialProductData
        
        if let initialData = initialProductData, initialData.slug == productSlug {
            self.product = initialData
        }
        // Rufe fetchProductDetails immer auf, um sicherzustellen, dass die Daten aktuell sind
        // und um Variationen zu laden, falls nötig.
        fetchProductDetails()
    }

    func fetchProductDetails() {
        // Verbesserte Logik, um unnötiges Neuladen zu vermeiden
        if let p = product, p.slug == self.initialProductSlug {
            // Produkt mit korrektem Slug ist bereits geladen.
            // Prüfe, ob Variationen geladen werden müssen/sollten.
            if p.type == .variable {
                if variations.isEmpty && !p.variations.isEmpty {
                    // Variationen fehlen, aber Produkt hat welche -> laden
                } else {
                    // Produkt und ggf. Variationen sind bereits geladen
                     print("ProductDetailViewModel: Details für \(self.initialProductSlug) scheinen aktuell zu sein.")
                    // Wenn initialProductData gesetzt war, aber isLoading noch true ist (z.B. von einem vorherigen abgebrochenen Ladevorgang),
                    // dann isLoading zurücksetzen.
                    if isLoading { isLoading = false }
                    return
                }
            } else {
                // Einfaches Produkt ist geladen
                 print("ProductDetailViewModel: Details für \(self.initialProductSlug) scheinen aktuell zu sein.")
                if isLoading { isLoading = false }
                return
            }
        }

        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedProduct = try await WooCommerceAPIManager.shared.getProductBySlug(productSlug: self.initialProductSlug)
                
                guard let mainProduct = fetchedProduct else {
                    self.errorMessage = "Produkt \"\(self.initialProductSlug)\" nicht gefunden."
                    self.product = nil
                    self.isLoading = false
                    return
                }
                self.product = mainProduct
                
                if mainProduct.type == .variable && !mainProduct.variations.isEmpty {
                    self.variations = try await WooCommerceAPIManager.shared.getProductVariations(productId: mainProduct.id)
                } else {
                    self.variations = []
                }
            } catch let error as WooCommerceAPIError { // Stelle sicher, dass WooCommerceAPIError hier bekannt ist
                self.errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
                print("ProductDetailViewModel Error loading product \(self.initialProductSlug): \(error)")
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
                print("ProductDetailViewModel Unknown Error loading product \(self.initialProductSlug): \(error)")
            }
            isLoading = false
        }
    }

    @Published var isAddingToCart: Bool = false
    @Published var addToCartError: String?
    @Published var addToCartSuccessMessage: String?

    var selectedVariation: WooCommerceProductVariation? {
        guard let p = product, p.type == .variable, !variations.isEmpty else { return nil }
        // Stelle sicher, dass für jedes variierende Attribut eine Option ausgewählt wurde.
        let varyingAttributes = p.attributes.filter { $0.variation }
        guard !varyingAttributes.isEmpty else { return p.variations.isEmpty ? nil : variations.first } // Falls keine variierenden Attribute definiert, aber Variationen da sind? (Sonderfall)

        let allRequiredAttributesSelected = varyingAttributes.allSatisfy { attrDef in
            let attrSlug = attrDef.slug ?? attrDef.name.lowercased().replacingOccurrences(of: " ", with: "-")
            return selectedAttributes[attrSlug] != nil && !selectedAttributes[attrSlug]!.isEmpty
        }
        guard allRequiredAttributesSelected else { return nil }

        return variations.first { variation in
            variation.attributes.allSatisfy { varAttr in // varAttr ist WooCommerceProductVariation.VariationAttribute
                let attributeDefinition = p.attributes.first(where: { $0.id == varAttr.id || $0.name == varAttr.name })
                let attributeSlugForSelection = attributeDefinition?.slug ?? attributeDefinition?.name.lowercased().replacingOccurrences(of: " ", with: "-") ?? ""
                let selectedOptionSlug = selectedAttributes[attributeSlugForSelection]
                
                // Der Slug der Variation's Option
                let variationOptionSlug = varAttr.slug ?? varAttr.option.lowercased().replacingOccurrences(of: " ", with: "-")
                
                return selectedOptionSlug == variationOptionSlug
            }
        }
    }
    
    var canPurchase: Bool {
        let currentProduct = self.product
        let currentStockStatus: StockStatus?
        let isPurchasable: Bool?
        let areBackordersAllowed: Bool?

        if currentProduct?.type == .variable {
            guard let variation = selectedVariation else { return false } // Ohne gewählte, passende Variation nicht kaufbar
            isPurchasable = variation.purchasable
            currentStockStatus = variation.stockStatus
            areBackordersAllowed = variation.backordersAllowed
        } else if let p = currentProduct {
            isPurchasable = p.purchasable
            currentStockStatus = p.stockStatus
            areBackordersAllowed = p.backordersAllowed
        } else {
            return false // Kein Produkt geladen
        }
        
        guard let purchasable = isPurchasable, purchasable else { return false }
        guard let stock = currentStockStatus else { return false } // Sollte nicht passieren

        if stock == .outofstock {
            return areBackordersAllowed == true
        }
        return true // .instock oder .onbackorder (onbackorder ist per Definition kaufbar)
    }

    func addToCart() {
        guard let mainProduct = product else {
            addToCartError = "Produkt nicht geladen."; return
        }
        
        let productIdToAdd: Int
        var variationIdToAdd: Int? = nil
        
        if mainProduct.type == .variable {
            guard let variation = selectedVariation else {
                addToCartError = "Bitte wählen Sie alle Produktoptionen aus."; return
            }
            guard variation.purchasable && (variation.stockStatus != .outofstock || variation.backordersAllowed) else {
                 addToCartError = "Ausgewählte Variante ist nicht verfügbar."; return
            }
            productIdToAdd = mainProduct.id // Hauptprodukt-ID für den API Call bei Variationen
            variationIdToAdd = variation.id
        } else {
            guard mainProduct.purchasable && (mainProduct.stockStatus != .outofstock || mainProduct.backordersAllowed) else {
                 addToCartError = "Produkt ist nicht verfügbar."; return
            }
            productIdToAdd = mainProduct.id
        }

        isAddingToCart = true
        addToCartError = nil
        addToCartSuccessMessage = nil

        Task {
            do {
                try await CartAPIManager.shared.addItem(
                    productId: productIdToAdd,
                    quantity: 1, // TODO: Mengenauswahl aus der UI hier verwenden
                    variationId: variationIdToAdd
                )
                addToCartSuccessMessage = "\(mainProduct.name) wurde zum Warenkorb hinzugefügt."
            } catch {
                addToCartError = "Fehler beim Hinzufügen: \(error.localizedDescription)"
            }
            isAddingToCart = false
        }
    }
    
    func selectAttribute(attributeDefinitionSlug: String, optionValueSlug: String) {
        selectedAttributes[attributeDefinitionSlug] = optionValueSlug
        // objectWillChange.send() // Oft nicht mehr nötig mit @Published für selectedAttributes,
                               // aber wenn selectedVariation davon abhängt, kann es helfen.
        // Wichtig: Reset cart messages, da die Auswahl die Kaufbarkeit ändern kann
        addToCartError = nil
        addToCartSuccessMessage = nil
    }
}
