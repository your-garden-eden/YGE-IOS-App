// Features/Products/ViewModels/ProductDetailViewModel.swift
import SwiftUI // Für @MainActor, @Published

// Stelle sicher, dass diese Typen hier bekannt sind oder importiert werden
// import YourAppModels // Beispiel, falls sie in einem eigenen Modul liegen

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var product: WooCommerceProduct?
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var selectedAttributes: [String: String] = [:] // Key: Attribut-Slug (z.B. "pa_farbe"), Value: Options-Slug (z.B. "rot")
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Hält den Slug, mit dem das VM für die aktuell geladenen Daten (product, variations) initialisiert/geladen wurde.
    // Nützlich, um zu prüfen, ob die Daten noch zum gewünschten Produkt gehören.
    var productSlugForCurrentData: String?

    private let initialProductSlug: String // Der Slug, mit dem das VM *ursprünglich* initialisiert wurde

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        self.initialProductSlug = productSlug
        
        if let initialData = initialProductData, initialData.slug == productSlug {
            self.product = initialData
            self.productSlugForCurrentData = initialData.slug
            // Wenn initialData ein variables Produkt ist und Variations-IDs hat, aber keine vollen Variationen,
            // könnten wir hier schon das Laden der Variationen anstoßen oder im fetchProductDetails handhaben.
        }
        fetchProductDetails() // Immer aufrufen, um ggf. zu aktualisieren oder Variationen zu laden
    }

    func fetchProductDetails() {
        // Nur laden, wenn der gewünschte Slug nicht mit dem Slug der aktuellen Daten übereinstimmt,
        // oder wenn es ein variables Produkt ist und die Variationen fehlen.
        if let p = product, p.slug == self.initialProductSlug, productSlugForCurrentData == self.initialProductSlug {
            if p.type == .variable {
                // Wenn Variationen nötig sind (Produkt hat Variations-IDs) und sie noch nicht geladen wurden
                if !p.variations.isEmpty && self.variations.isEmpty && !isLoading {
                    // Fährt mit dem Laden fort (speziell für Variationen)
                    print("ProductDetailViewModel: Product \(self.initialProductSlug) is loaded, but variations are missing. Fetching variations...")
                } else if isLoading {
                    // Bereits am Laden, nichts tun.
                    return
                } else {
                    // Produkt und ggf. Variationen sind bereits geladen und aktuell
                    print("ProductDetailViewModel: Details for \(self.initialProductSlug) are already loaded and current.")
                    return
                }
            } else {
                // Einfaches Produkt ist geladen und aktuell
                print("ProductDetailViewModel: Details for \(self.initialProductSlug) are already loaded and current.")
                if isLoading { isLoading = false } // Falls ein vorheriger Ladevorgang hängen geblieben ist
                return
            }
        } else if isLoading {
             print("ProductDetailViewModel: Already loading details for \(self.initialProductSlug). Skipping.")
            return // Bereits am Laden
        }


        isLoading = true
        errorMessage = nil
        
        Task {
            // Setze den productSlugForCurrentData vor dem Netzwerkaufruf auf den zu ladenden Slug,
            // oder erst nach erfolgreichem Laden des Hauptprodukts. Letzteres ist sicherer.
            let slugToLoad = self.initialProductSlug
            
            do {
                let fetchedProduct = try await WooCommerceAPIManager.shared.getProductBySlug(productSlug: slugToLoad)
                
                guard let mainProduct = fetchedProduct else {
                    self.errorMessage = "Produkt \"\(slugToLoad)\" nicht gefunden."
                    self.product = nil
                    self.variations = []
                    self.productSlugForCurrentData = nil // Zurücksetzen, da Laden fehlschlug
                    self.isLoading = false
                    return
                }
                
                // Erfolgreich geladen, setze product und productSlugForCurrentData
                self.product = mainProduct
                self.productSlugForCurrentData = mainProduct.slug // Wichtig für die Logik oben
                
                if mainProduct.type == .variable && !mainProduct.variations.isEmpty { // variations Array im Product enthält nur IDs
                    print("ProductDetailViewModel: Fetching variations for product ID \(mainProduct.id)...")
                    self.variations = try await WooCommerceAPIManager.shared.getProductVariations(productId: mainProduct.id)
                    print("ProductDetailViewModel: Successfully fetched \(self.variations.count) variations.")
                } else {
                    self.variations = []
                }
            } catch let error as WooCommerceAPIError {
                self.errorMessage = "Fehler beim Laden von \"\(slugToLoad)\": \(error.localizedDescription)"
                print("ProductDetailViewModel Error loading product \(slugToLoad): \(error)")
                // product und variations nicht zurücksetzen, wenn schon alte Daten da waren? Oder doch?
                // Hängt von der gewünschten UX ab. Hier werden sie nicht explizit zurückgesetzt,
                // außer wenn das Hauptprodukt nicht gefunden wurde.
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten beim Laden von \"\(slugToLoad)\": \(error.localizedDescription)"
                print("ProductDetailViewModel Unknown Error loading product \(slugToLoad): \(error)")
            }
            isLoading = false
        }
    }

    @Published var isAddingToCart: Bool = false
    @Published var addToCartError: String?
    @Published var addToCartSuccessMessage: String?

    var selectedVariation: WooCommerceProductVariation? {
        guard let p = product, p.type == .variable, !variations.isEmpty else { return nil }
        
        let varyingAttributesDefinitions = p.attributes.filter { $0.variation }
        guard !varyingAttributesDefinitions.isEmpty else {
            // Produkt ist variabel, hat aber keine als "variation=true" markierten Attribute.
            // Das könnte bedeuten, dass alle Variationen gültig sind oder es nur eine Default-Variation gibt.
            // Wenn es Variationen gibt, die keine Attribute haben, nimm die erste.
            // Dies ist ein Edge-Case. Normalerweise haben variable Produkte variierende Attribute.
            return variations.first // Oder nil, je nachdem, wie WC dies handhabt.
        }

        // Prüfen, ob für jedes als "variation" markierte Attribut eine Option in `selectedAttributes` gewählt wurde.
        let allRequiredAttributesSelected = varyingAttributesDefinitions.allSatisfy { attrDef in
            let attrSlug = attrDef.slug ?? attrDef.name.lowercased().replacingOccurrences(of: " ", with: "-")
            return selectedAttributes[attrSlug] != nil && !selectedAttributes[attrSlug]!.isEmpty
        }
        
        guard allRequiredAttributesSelected else {
            // Nicht alle benötigten Attribute sind ausgewählt.
            return nil
        }

        return variations.first { variation in
            // Eine Variation passt, wenn alle ihre Attribute mit den in `selectedAttributes` gewählten Optionen übereinstimmen.
            variation.attributes.allSatisfy { variationAttributeOption in // WooCommerceProductVariation.VariationAttribute
                // Finde die Definition des Attributs im Hauptprodukt (um den Slug zu bekommen, der in selectedAttributes als Key verwendet wird)
                let attributeDefinition = p.attributes.first { $0.id == variationAttributeOption.id || $0.name == variationAttributeOption.name }
                guard let attrDefSlug = attributeDefinition?.slug ?? attributeDefinition?.name.lowercased().replacingOccurrences(of: " ", with: "-") else {
                    return false // Sollte nicht passieren, wenn Daten konsistent sind
                }
                
                let selectedOptionForThisAttribute = selectedAttributes[attrDefSlug]
                
                // Der Slug der Option dieser Variation für dieses Attribut
                let currentVariationOptionSlug = variationAttributeOption.slug ?? variationAttributeOption.option.lowercased().replacingOccurrences(of: " ", with: "-")
                
                return selectedOptionForThisAttribute == currentVariationOptionSlug
            }
        }
    }
    
    var canPurchase: Bool {
        let currentProductForPurchase = self.product
        let currentStockStatus: StockStatus?
        let isPurchasable: Bool?
        let areBackordersAllowed: Bool?

        if currentProductForPurchase?.type == .variable {
            guard let variation = selectedVariation else { return false }
            isPurchasable = variation.purchasable
            currentStockStatus = variation.stockStatus
            areBackordersAllowed = variation.backordersAllowed
        } else if let p = currentProductForPurchase {
            isPurchasable = p.purchasable
            currentStockStatus = p.stockStatus
            areBackordersAllowed = p.backordersAllowed
        } else {
            return false // Kein Produkt geladen
        }
        
        guard let purchasable = isPurchasable, purchasable else { return false }
        
        // Wenn stock_status nil ist, aber purchasable true, behandeln wir es als kaufbar
        // (WooCommerce Default ist 'instock', wenn nicht anders gesetzt und manage_stock=false)
        guard let stock = currentStockStatus else { return true }


        switch stock {
        case .instock, .onbackorder:
            return true
        case .outofstock:
            return areBackordersAllowed == true
        }
    }

    // Hinzugefügte Menge-Property
    @Published var quantity: Int = 1

    func addToCart() {
        guard let mainProduct = product else {
            addToCartError = "Produkt nicht geladen."; return
        }
        
        let productIdToAdd: Int
        var variationAttributesForCart: [WooCommerceStoreCartItemVariationAttribute]? = nil // Korrekter Typ
        var nameForSuccessMessage = mainProduct.name
        
        if mainProduct.type == .variable {
            guard let variation = selectedVariation else {
                addToCartError = "Bitte wählen Sie alle Produktoptionen aus."; return
            }
            // `canPurchase` prüft bereits die Purchasability und den Stock der Variation
            guard canPurchase else {
                 addToCartError = "Ausgewählte Variante ist nicht verfügbar oder nicht kaufbar."; return
            }
            
            productIdToAdd = mainProduct.id // Hauptprodukt-ID
            
            var tempVariationAttributes: [WooCommerceStoreCartItemVariationAttribute] = []
            // `selectedAttributes` enthält { "pa_farbe": "rot", "pa_groesse": "mittel" }
            // Wir müssen sicherstellen, dass wir nur die Attribute verwenden, die für DIESE `selectedVariation` relevant sind.
            // Die `selectedVariation.attributes` (Typ: [WooCommerceProductVariation.VariationAttribute]) gibt uns die korrekten Attribute der Variante.
            for varAttrOption in variation.attributes { // varAttrOption ist WooCommerceProductVariation.VariationAttribute
                 // Finde die Definition des Attributs im Hauptprodukt, um den Slug zu bekommen, der für die API als "attribute" benötigt wird.
                let attributeDefinition = mainProduct.attributes.first { $0.id == varAttrOption.id || $0.name == varAttrOption.name }
                guard let apiAttributeSlug = attributeDefinition?.slug ?? attributeDefinition?.name.lowercased().replacingOccurrences(of: " ", with: "-") else {
                    print("ProductDetailViewModel: Konnte Attribut-Slug für \(varAttrOption.name) nicht finden. Überspringe.")
                    continue
                }
                // Der Wert ist der Slug der Option
                let apiOptionSlug = varAttrOption.slug ?? varAttrOption.option.lowercased().replacingOccurrences(of: " ", with: "-")
                tempVariationAttributes.append(WooCommerceStoreCartItemVariationAttribute(attribute: apiAttributeSlug, value: apiOptionSlug))
            }

            if tempVariationAttributes.isEmpty && !variation.attributes.isEmpty {
                 // Sollte nicht passieren, wenn variation.attributes korrekt befüllt sind und die Slugs gefunden wurden.
                 addToCartError = "Fehler bei der Verarbeitung der Variantendetails."
                 return
            }
            variationAttributesForCart = tempVariationAttributes.isEmpty ? nil : tempVariationAttributes

            // Für die Erfolgsmeldung
            let variationDescription = variation.attributes.map { "\($0.name): \($0.option)" }.joined(separator: ", ")
            nameForSuccessMessage = "\(mainProduct.name) (\(variationDescription))"

        } else { // Einfaches Produkt
            guard canPurchase else {
                 addToCartError = "Produkt ist nicht verfügbar oder nicht kaufbar."; return
            }
            productIdToAdd = mainProduct.id
            // variationAttributesForCart bleibt nil
        }

        isAddingToCart = true
        addToCartError = nil
        addToCartSuccessMessage = nil

        Task {
            do {
                // Stelle sicher, dass CartAPIManager.addItem jetzt `throws` ist
                try await CartAPIManager.shared.addItem(
                    productId: productIdToAdd,
                    quantity: self.quantity, // Verwende die @Published quantity
                    variation: variationAttributesForCart
                )
                addToCartSuccessMessage = "\(nameForSuccessMessage) wurde zum Warenkorb hinzugefügt."
                self.quantity = 1 // Menge nach Erfolg zurücksetzen
            } catch { // Fängt WooCommerceAPIError und andere Fehler, die von addItem geworfen werden
                addToCartError = "Fehler beim Hinzufügen: \(error.localizedDescription)"
                print("ProductDetailViewModel: addToCart error: \(error)")
            }
            isAddingToCart = false
        }
    }
    
    func selectAttribute(attributeDefinitionSlug: String, optionValueSlug: String) {
        // Wenn der optionValueSlug leer ist, bedeutet das "keine Auswahl" für dieses Attribut
        if optionValueSlug.isEmpty {
            selectedAttributes.removeValue(forKey: attributeDefinitionSlug)
        } else {
            selectedAttributes[attributeDefinitionSlug] = optionValueSlug
        }
        
        // Reset cart messages und quantity, da die Auswahl die Kaufbarkeit/Preis ändern kann
        addToCartError = nil
        addToCartSuccessMessage = nil
        self.quantity = 1 // Setze Menge auf 1 zurück bei Attributänderung
        
        // Manuelles Auslösen eines Updates, falls `selectedVariation` und `canPurchase`
        // nicht automatisch von der Änderung von `selectedAttributes` getriggert werden.
        // Oft reicht @Published für selectedAttributes, aber komplexe Computed Properties können das erfordern.
        // objectWillChange.send() // Normalerweise nicht mehr nötig mit SwiftUI 3+ und @Published
    }

    // Für die Mengenauswahl in der UI
    func incrementQuantity() {
        quantity += 1
    }

    func decrementQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
}
