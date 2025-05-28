// Datei: ProductDetailViewModel.swift
// Pfad: Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductDetailViewModel.swift

import SwiftUI
import Combine // Obwohl Combine nicht mehr aktiv für API-Calls genutzt wird, kann es für andere @Published-Reaktionen nützlich sein.

@MainActor
class ProductDetailViewModel: ObservableObject {
    // MARK: - Produkt und Variationsdaten
    @Published var product: WooCommerceProduct?
    @Published var variations: [WooCommerceProductVariation] = []

    // MARK: - Lade- und Fehlerzustände
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Benutzerauswahl
    @Published var selectedAttributes: [String: String] = [:] // Key: Attribut-Slug (z.B. "pa_farbe"), Value: Options-Slug (z.B. "rot")
    @Published var quantity: Int = 1

    // MARK: - Zustände für Warenkorb-Interaktion
    @Published var isAddingToCart: Bool = false
    @Published var addToCartError: String?
    @Published var addToCartSuccessMessage: String?
    
    private let initialProductSlug: String
    private var productSlugForCurrentData: String? // Um unnötige Neuladevorgänge zu vermeiden

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        self.initialProductSlug = productSlug
        
        if let initialData = initialProductData, initialData.slug == productSlug {
            self.product = initialData
            self.productSlugForCurrentData = initialData.slug
            // Wenn initiale Produktdaten ein variables Produkt sind und Variations-IDs haben,
            // aber die Variationen selbst noch nicht geladen sind.
            // fetchProductDetails wird dies handhaben.
            print("ProductDetailViewModel (init): Initial product data provided for slug '\(productSlug)'. Name: '\(initialData.name)'")
        } else {
            print("ProductDetailViewModel (init): No (matching) initial product data for slug '\(productSlug)'. Will fetch.")
        }
        // Rufe fetchProductDetails auf, um ggf. volle Daten oder Variationen zu laden.
        fetchProductDetails()
    }

    func fetchProductDetails() {
        // Bereits existierende Logik zur Vermeidung von Mehrfach-Laden
        if let p = product, p.slug == self.initialProductSlug, productSlugForCurrentData == self.initialProductSlug {
            if p.type == .variable {
                if !p.variations.isEmpty && self.variations.isEmpty && !isLoading {
                    print("ProductDetailViewModel (fetchProductDetails): Product '\(self.initialProductSlug)' base loaded, has variation IDs (\(p.variations.count)), but local variations array is empty. Will proceed to fetch full variations.")
                } else if isLoading {
                    print("ProductDetailViewModel (fetchProductDetails): Already loading details for '\(self.initialProductSlug)'. Aborting.")
                    return
                } else if p.variations.isEmpty && self.variations.isEmpty {
                     print("ProductDetailViewModel (fetchProductDetails): Product '\(self.initialProductSlug)' is variable but has no variation IDs listed in product data.")
                    if isLoading { self.isLoading = false }
                    return
                } else if !self.variations.isEmpty {
                    print("ProductDetailViewModel (fetchProductDetails): Details and variations for '\(self.initialProductSlug)' seem current.")
                    if isLoading { self.isLoading = false }
                    return
                }
            } else { // Für einfache Produkte
                print("ProductDetailViewModel (fetchProductDetails): Details for simple product '\(self.initialProductSlug)' seem current.")
                if isLoading { self.isLoading = false }
                return
            }
        } else if isLoading {
            print("ProductDetailViewModel (fetchProductDetails): Already loading details for '\(self.initialProductSlug)'. Aborting.")
            return
        }

        print("ProductDetailViewModel (fetchProductDetails): Proceeding to load/update data for slug: \(initialProductSlug)")
        self.isLoading = true
        self.errorMessage = nil
        let slugToLoad = self.initialProductSlug
        
        Task {
            defer {
                // Stelle sicher, dass isLoading auf dem MainActor aktualisiert wird
                Task { @MainActor in self.isLoading = false }
            }
            do {
                // Produkt nur neu laden, wenn es noch nicht existiert oder der Slug nicht übereinstimmt
                if self.product == nil || self.product?.slug != slugToLoad {
                    print("ProductDetailViewModel (fetchProductDetails Task): Fetching main product data for slug: \(slugToLoad)")
                    let fetchedProduct = try await WooCommerceAPIManager.shared.getProductBySlug(productSlug: slugToLoad)
                    
                    guard let mainProduct = fetchedProduct else {
                        self.errorMessage = "Produkt \"\(slugToLoad)\" nicht gefunden."
                        self.product = nil; self.variations = []; self.productSlugForCurrentData = nil
                        return
                    }
                    self.product = mainProduct
                    self.productSlugForCurrentData = mainProduct.slug
                     print("ProductDetailViewModel (fetchProductDetails Task): Successfully fetched main product data for '\(mainProduct.name)' (Slug: \(slugToLoad)).")
                } else {
                    print("ProductDetailViewModel (fetchProductDetails Task): Main product data for slug '\(slugToLoad)' is already current.")
                }
                
                // Variationen laden, wenn es ein variables Produkt ist und Variations-IDs vorhanden sind
                if let currentProduct = self.product, currentProduct.type == .variable, !currentProduct.variations.isEmpty {
                    if self.variations.isEmpty {
                        print("ProductDetailViewModel (fetchProductDetails Task): Fetching variations for product ID \(currentProduct.id) ('\(currentProduct.name)')...")
                        self.variations = try await WooCommerceAPIManager.shared.getProductVariations(productId: currentProduct.id)
                        print("ProductDetailViewModel (fetchProductDetails Task): Fetched \(self.variations.count) variations.")
                        setDefaultAttributeSelections()
                    } else {
                        print("ProductDetailViewModel (fetchProductDetails Task): Variations for '\(currentProduct.name)' already loaded (\(self.variations.count) found). Attempting to set default attributes if needed.")
                        setDefaultAttributeSelections() // Auch hier aufrufen, falls Produkt schon da war, aber Defaults noch nicht gesetzt
                    }
                } else {
                    self.variations = []
                    if let currentProduct = self.product, currentProduct.type == .variable && currentProduct.variations.isEmpty {
                        print("ProductDetailViewModel (fetchProductDetails Task): Product '\(currentProduct.name)' is variable but has no variation IDs. Variations array cleared.")
                    } else if let currentProduct = self.product, currentProduct.type != .variable {
                         print("ProductDetailViewModel (fetchProductDetails Task): Product '\(currentProduct.name)' is not variable. Variations array cleared.")
                    }
                }
            } catch let error as WooCommerceAPIError {
                self.errorMessage = "Fehler beim Laden von \"\(slugToLoad)\": \(error.localizedDescription)"
                print("ProductDetailViewModel Error (WooCommerceAPIError) loading product \(slugToLoad): \(error)")
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
                print("ProductDetailViewModel Error (Unknown) loading product \(slugToLoad): \(error)")
            }
        }
    }

    // MARK: - Computed Properties für die View
    var selectedVariation: WooCommerceProductVariation? {
        guard let p = product, p.type == .variable, !variations.isEmpty else { return nil }
        let varyingAttributesDefinitions = p.attributes.filter { $0.variation }
        
        if varyingAttributesDefinitions.isEmpty {
            return variations.count == 1 ? variations.first : nil
        }

        let allRequiredAttributesSelected = varyingAttributesDefinitions.allSatisfy { attrDef in
            let key = attrDef.slugOrNameAsSlug()
            return selectedAttributes[key] != nil && !selectedAttributes[key]!.isEmpty
        }
        guard allRequiredAttributesSelected else { return nil }

        return variations.first { variation in
            variation.attributes.allSatisfy { variationAttributeOption in
                let attributeTaxonomySlug = variationAttributeOption.slugOrNameAsSlug() // Name des Attributs (z.B. "pa_farbe")
                guard let selectedOptionSlugForThisAttribute = selectedAttributes[attributeTaxonomySlug] else {
                    // Wenn für dieses Attribut (z.B. "pa_farbe") keine Auswahl getroffen wurde,
                    // kann diese Variation nicht die gesuchte sein, *falls* dieses Attribut Teil der varyingAttributesDefinitions ist.
                    // Da wir aber oben allRequiredAttributesSelected prüfen, sollte dieser Fall nur für
                    // Attribute der Variation auftreten, die nicht zu den "varyingAttributesDefinitions" gehören (z.B. "Any Size").
                    // In diesem Fall sollte das Attribut ignoriert werden.
                    return !varyingAttributesDefinitions.contains(where: {$0.slugOrNameAsSlug() == attributeTaxonomySlug })
                }
                return selectedOptionSlugForThisAttribute == variationAttributeOption.optionAsSlug()
            }
        }
    }
    
    var displayPrice: String {
        selectedVariation?.price ?? product?.price ?? "N/A"
    }

    var displayRegularPrice: String? {
        let currentPriceString = selectedVariation?.price ?? product?.price
        let regularPriceString = selectedVariation?.regularPrice ?? product?.regularPrice
        let currentPriceValue = Double(currentPriceString ?? "")
        let regularPriceValue = Double(regularPriceString ?? "")
        guard let regPriceStr = regularPriceString, !regPriceStr.isEmpty else { return nil }
        if let cpVal = currentPriceValue, let rpVal = regularPriceValue {
            if rpVal > cpVal { return regPriceStr } else { return nil }
        } else if regPriceStr != currentPriceString { return regPriceStr }
        return nil
    }

    var displayImageSet: [WooCommerceImage] {
        if let variationImage = selectedVariation?.image { return [variationImage] }
        return product?.images ?? []
    }

    struct StockStatusDisplay { let text: String; let color: Color }
    var displayStockStatus: StockStatusDisplay {
        let status: StockStatus?; let backordersAllowed: Bool?
        if let variation = selectedVariation {
            status = variation.stockStatus; backordersAllowed = variation.backordersAllowed
        } else if let p = product {
            status = p.stockStatus; backordersAllowed = p.backordersAllowed
        } else { return StockStatusDisplay(text: "Status unbekannt", color: AppColors.textMuted) }
        
        switch status {
        case .instock: return StockStatusDisplay(text: "Auf Lager", color: AppColors.inStock)
        case .outofstock: return StockStatusDisplay(text: backordersAllowed == true ? "Lieferbar auf Anfrage" : "Ausverkauft", color: backordersAllowed == true ? AppColors.warning : AppColors.error)
        case .onbackorder: return StockStatusDisplay(text: "Lieferbar auf Anfrage", color: AppColors.warning)
        case .none: return product?.purchasable == true ? StockStatusDisplay(text: "Verfügbar", color: AppColors.info) : StockStatusDisplay(text: "Status unbekannt", color: AppColors.textMuted)
        }
    }
    
    var canPurchase: Bool {
        let stock: StockStatus?; let purchasable: Bool?; let backordersAllowed: Bool?
        if let variation = selectedVariation {
            purchasable = variation.purchasable; stock = variation.stockStatus; backordersAllowed = variation.backordersAllowed
        } else if let p = product, p.type != .variable {
            purchasable = p.purchasable; stock = p.stockStatus; backordersAllowed = p.backordersAllowed
        } else if let p = product, p.type == .variable && variations.isEmpty && p.variations.isEmpty { // Variables Produkt ohne definierte Variationen
             purchasable = p.purchasable; stock = p.stockStatus; backordersAllowed = p.backordersAllowed
        } else if product?.type == .variable && selectedVariation == nil { return false } // Variables Produkt, aber keine Variation ausgewählt
        else { return false }
        
        guard let isPurchasable = purchasable, isPurchasable else { return false }
        guard let stockStatus = stock else { return true }
        switch stockStatus {
        case .instock, .onbackorder: return true
        case .outofstock: return backordersAllowed == true
        }
    }

    // MARK: - Aktionen
    func selectAttribute(attributeDefinitionSlug: String, optionValueSlug: String) {
        if selectedAttributes[attributeDefinitionSlug] == optionValueSlug {
            // Optional: Auswahl aufheben, wenn derselbe Button erneut geklickt wird.
            // selectedAttributes.removeValue(forKey: attributeDefinitionSlug)
            // print("ProductDetailViewModel (selectAttribute): Deselected option '\(optionValueSlug)' for attribute '\(attributeDefinitionSlug)'")
        } else {
            selectedAttributes[attributeDefinitionSlug] = optionValueSlug
            print("ProductDetailViewModel (selectAttribute): Selected option '\(optionValueSlug)' for attribute '\(attributeDefinitionSlug)'")
        }
        // Reset cart messages and quantity when attributes change
        addToCartError = nil; addToCartSuccessMessage = nil; quantity = 1
        
        // Debugging output
        if let sv = selectedVariation { print("ProductDetailViewModel (selectAttribute): New selected variation ID: \(sv.id), Price: \(sv.price)") }
        else { print("ProductDetailViewModel (selectAttribute): No complete variation selected with current attributes: \(selectedAttributes)") }
    }

    private func setDefaultAttributeSelections() {
        guard let p = product, p.type == .variable, !variations.isEmpty else {
            print("ProductDetailViewModel (setDefaultAttributeSelections): Bedingungen nicht erfüllt (Produkt: \(product?.name ?? "N/A"), Typ: \(product?.type.rawValue ?? "N/A"), Variationen leer: \(variations.isEmpty)). Überspringe Default-Setzung.")
            return
        }
        
        print("ProductDetailViewModel (setDefaultAttributeSelections): Beginne mit Defaults für Produkt '\(p.name)' (ID: \(p.id))")
        var newSelections = self.selectedAttributes // Starte mit der aktuellen Auswahl, um bestehende manuelle Auswahl nicht zu überschreiben
        var selectionsWereUpdated = false

        let varyingAttributes = p.attributes.filter({ $0.variation })
        if varyingAttributes.isEmpty {
            print("ProductDetailViewModel (setDefaultAttributeSelections): Keine als 'variation' markierten Attribute im Produkt gefunden. Überspringe Default-Setzung.")
            return
        }
        print("ProductDetailViewModel (setDefaultAttributeSelections): Variierende Attribute im Produkt: \(varyingAttributes.map({ "'\($0.name)' (Slug: \($0.slugOrNameAsSlug()))" }).joined(separator: ", "))")
        if !p.defaultAttributes.isEmpty {
            print("ProductDetailViewModel (setDefaultAttributeSelections): Produkt Default-Attribute vorhanden: \(p.defaultAttributes.map({ "\($0.name): \($0.option)" }).joined(separator: ", "))")
        } else {
            print("ProductDetailViewModel (setDefaultAttributeSelections): Keine Produkt Default-Attribute im Produktobjekt gefunden.")
        }


        for attributeDef in varyingAttributes {
            let attrDefKey = attributeDef.slugOrNameAsSlug()

            if newSelections[attrDefKey] == nil { // Nur einen Default setzen, wenn für dieses Attribut noch keine Auswahl getroffen wurde
                var defaultOptionSlugToSet: String? = nil

                // 1. Versuche, den Default aus product.defaultAttributes zu nehmen
                if let productDefault = p.defaultAttributes.first(where: { defaultAttr in
                    // Vergleiche den Namen des Default-Attributs mit dem Namen der aktuellen Attribut-Definition
                    defaultAttr.name == attributeDef.name
                }) {
                    defaultOptionSlugToSet = productDefault.option.lowercased().replacingOccurrences(of: " ", with: "-")
                    print("ProductDetailViewModel (setDefaultAttributeSelections): Default für Attribut '\(attributeDef.name)' (Key: '\(attrDefKey)') aus Produkt-Defaults ('\(productDefault.name)') gefunden: Option-Slug '\(defaultOptionSlugToSet!)'")
                }
                
                // 2. Wenn kein Produkt-Default, nimm die erste verfügbare Option aus den Variationen als Fallback
                if defaultOptionSlugToSet == nil {
                    print("ProductDetailViewModel (setDefaultAttributeSelections): Kein Produkt-Default für '\(attributeDef.name)' (Key: '\(attrDefKey)') gefunden. Suche in den \(variations.count) geladenen Variationen...")
                    defaultOptionSlugToSet = variations.lazy.compactMap { variation -> String? in
                        variation.attributes.first { variationAttr in
                            (variationAttr.name == attributeDef.name) || // Vergleiche Name
                            (variationAttr.slugOrNameAsSlug() == attrDefKey) // Oder Slug der Attributdefinition
                        }?.optionAsSlug()
                    }.first
                    
                    if let slug = defaultOptionSlugToSet {
                        print("ProductDetailViewModel (setDefaultAttributeSelections): Default für Attribut '\(attributeDef.name)' (Key: '\(attrDefKey)') aus erster Variation gefunden: Option-Slug '\(slug)'")
                    } else {
                        print("ProductDetailViewModel (setDefaultAttributeSelections): Konnte auch keinen Default aus Variationen für Attribut '\(attributeDef.name)' (Key: '\(attrDefKey)') finden.")
                    }
                }

                if let finalDefaultSlug = defaultOptionSlugToSet {
                    newSelections[attrDefKey] = finalDefaultSlug
                    selectionsWereUpdated = true
                }
            } else {
                print("ProductDetailViewModel (setDefaultAttributeSelections): Attribut '\(attributeDef.name)' (Key: '\(attrDefKey)') hat bereits eine Auswahl: '\(newSelections[attrDefKey]!)'. Überspringe Default-Setzung.")
            }
        }

        if selectionsWereUpdated {
            self.selectedAttributes = newSelections
            print("ProductDetailViewModel (setDefaultAttributeSelections): Finale gesetzte Defaults: \(self.selectedAttributes)")
        } else {
            print("ProductDetailViewModel (setDefaultAttributeSelections): Keine Defaults mussten aktualisiert werden, oder alle Attribute hatten bereits eine Auswahl.")
        }
    }


    func addToCart() {
        guard let mainProduct = product else { addToCartError = "Produkt nicht geladen."; return }
        let productIdToAdd: Int; var variationAttributesForCart: [WooCommerceStoreCartItemVariationAttribute]? = nil
        var nameForSuccessMessage = mainProduct.name
        
        if mainProduct.type == .variable {
            guard let variation = selectedVariation else { addToCartError = "Bitte wählen Sie alle Produktoptionen aus."; return }
            guard canPurchase else { addToCartError = "Ausgewählte Variante ist nicht verfügbar oder nicht kaufbar."; return }
            productIdToAdd = mainProduct.id
            
            variationAttributesForCart = variation.attributes.map { varAttr in
                let attributeTaxonomySlug = varAttr.slugOrNameAsSlug() // z.B. "pa_farbe"
                // Der Wert sollte der Slug der ausgewählten Option für diese Taxonomie sein
                let optionValueSlug = selectedAttributes[attributeTaxonomySlug] ?? varAttr.optionAsSlug() // Fallback auf den Slug der Option der Variation
                return WooCommerceStoreCartItemVariationAttribute(attribute: attributeTaxonomySlug, value: optionValueSlug)
            }

            if variationAttributesForCart?.isEmpty ?? true && !variation.attributes.isEmpty {
                addToCartError = "Fehler bei der Verarbeitung der Variantendetails."; return
            }

            let variationDescriptionParts = variation.attributes.compactMap { attr -> String? in
                let attrTaxonomySlug = attr.slugOrNameAsSlug()
                // Finde den Anzeigenamen der ausgewählten Option
                // 1. Suche in den Produktattribut-Definitionen nach der Option mit dem ausgewählten Slug
                let selectedOptionDisplayName = product?.attributes
                    .first(where: {$0.slugOrNameAsSlug() == attrTaxonomySlug})?.options
                    .first(where: {$0.lowercased().replacingOccurrences(of: " ", with: "-") == selectedAttributes[attrTaxonomySlug]})
                
                return "\(attr.name): \(selectedOptionDisplayName ?? attr.option)" // Fallback auf den Optionsnamen der Variation
            }
            nameForSuccessMessage = "\(mainProduct.name) (\(variationDescriptionParts.joined(separator: ", ")))"

        } else { // Für einfache Produkte
            guard canPurchase else { addToCartError = "Produkt ist nicht verfügbar oder nicht kaufbar."; return }
            productIdToAdd = mainProduct.id
        }

        isAddingToCart = true; addToCartError = nil; addToCartSuccessMessage = nil
        Task {
            defer { isAddingToCart = false }
            do {
                try await CartAPIManager.shared.addItem(productId: productIdToAdd, quantity: self.quantity, variation: variationAttributesForCart)
                addToCartSuccessMessage = "\(nameForSuccessMessage) wurde zum Warenkorb hinzugefügt."
                self.quantity = 1 // Menge zurücksetzen
            } catch {
                addToCartError = "Fehler: \((error as? LocalizedError)?.localizedDescription ?? error.localizedDescription)"
                print("ProductDetailViewModel: addToCart error: \(error)")
            }
        }
    }
    
    // MARK: - Mengenanpassung
    func incrementQuantity() {
        quantity += 1; addToCartSuccessMessage = nil; addToCartError = nil
    }

    func decrementQuantity() {
        if quantity > 1 { quantity -= 1 }
        addToCartSuccessMessage = nil; addToCartError = nil
    }
}

// MARK: - Helper Extensions for Slug Generation (sollten globaler oder im jeweiligen Modell sein)
// Diese sind jetzt hier zur Übersichtlichkeit, könnten aber auch in die Model-Dateien verschoben werden.

extension WooCommerceAttribute {
    func slugOrNameAsSlug() -> String {
        // Nutze den expliziten Slug, wenn vorhanden, ansonsten generiere aus dem Namen.
        // WooCommerce verwendet oft den Attribut-Namen (z.B. "Farbe") als Basis für den internen Key,
        // während der "slug" (z.B. "pa_farbe") die eigentliche Taxonomie ist.
        // Für die `selectedAttributes` verwenden wir konsistent den Taxonomie-Slug, wenn vorhanden.
        return slug ?? name.lowercased().replacingOccurrences(of: " ", with: "-")
    }
}

extension WooCommerceProductVariation.VariationAttribute {
    func slugOrNameAsSlug() -> String {
        // Bei VariationAttribute ist 'name' oft die Referenz zur Taxonomie (z.B. "Farbe" oder "pa_farbe").
        // 'slug' ist hier oft nil. Wir nehmen den Namen als Basis für den Key.
        return name.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    func optionAsSlug() -> String {
        // Der 'option'-Wert ist der ausgewählte Wert (z.B. "Rot", "Blau").
        // Diesen machen wir zu einem Slug für Vergleiche.
        return option.lowercased().replacingOccurrences(of: " ", with: "-")
    }
}
