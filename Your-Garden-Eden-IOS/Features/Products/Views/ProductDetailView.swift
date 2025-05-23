// Your-Garden-Eden-IOS/Features/Products/Views/ProductDetailView.swift
import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedImageIndex: Int = 0
    // @State private var quantity: Int = 1 // Für Mengenauswahl

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productSlug: productSlug, initialProductData: initialProductData))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isLoading && viewModel.product == nil {
                    ProgressView("Lade Details...")
                        .frame(maxWidth: .infinity, minHeight: 300)
                } else if let errorMessage = viewModel.errorMessage, viewModel.product == nil {
                    // ... (Fehleranzeige wie zuvor) ...
                } else if let product = viewModel.product { // Sicherstellen, dass product nicht nil ist
                    // Produktbildgalerie
                    productImageGallery(
                        images: viewModel.selectedVariation?.image.map { [$0] } ?? product.images,
                        productName: product.name
                    )
                    .padding(.bottom)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(product.name)
                            .font(.title).bold().lineLimit(3)

                        HStack(alignment: .firstTextBaseline) {
                            Text(viewModel.selectedVariation?.price ?? product.price) // Preis der Variation oder des Hauptprodukts
                                .font(.title2).bold().foregroundColor(Color.accentColor)
                            
                            if let regularPriceToShow = determineRegularPrice(product: product, variation: viewModel.selectedVariation) {
                                Text(regularPriceToShow)
                                    .font(.subheadline).strikethrough().foregroundColor(.gray)
                            }
                            Spacer()
                        }

                        if !product.shortDescription.isEmpty {
                            Text(stripHtml(from: product.shortDescription))
                                .font(.callout).foregroundColor(.secondary)
                        }
                        
                        if product.type == .variable && !product.attributes.filter({ $0.variation }).isEmpty {
                            Divider().padding(.vertical, 8)
                            ForEach(product.attributes.filter { $0.variation }) { attribute in
                                AttributeSelectorView(
                                    attribute: attribute,
                                    variations: viewModel.variations, // Übergebe alle Variationen
                                    selectedOptionSlugForThisAttribute: viewModel.selectedAttributes[attribute.slug ?? attribute.name.lowercased().replacingOccurrences(of: " ", with: "-")],
                                    onSelect: { selectedOptionSlug in
                                        viewModel.selectAttribute(
                                            attributeDefinitionSlug: attribute.slug ?? attribute.name.lowercased().replacingOccurrences(of: " ", with: "-"),
                                            optionValueSlug: selectedOptionSlug
                                        )
                                    }
                                )
                            }
                            Divider().padding(.vertical, 8)
                        }

                        Text(stockStatusText(product: product, variation: viewModel.selectedVariation))
                            .font(.caption.weight(.medium))
                            .foregroundColor(stockStatusColor(product: product, variation: viewModel.selectedVariation))
                            .padding(.vertical, 4).padding(.horizontal, 8)
                            .background(stockStatusColor(product: product, variation: viewModel.selectedVariation).opacity(0.1))
                            .clipShape(Capsule())
                        
                        Button(action: viewModel.addToCart) { /* ... */ }
                        .fontWeight(.semibold).frame(height: 50).frame(maxWidth: .infinity)
                        .background(viewModel.canPurchase && !viewModel.isAddingToCart ? Color.accentColor : Color.gray.opacity(0.7))
                        .foregroundColor(.white).cornerRadius(10)
                        .disabled(!viewModel.canPurchase || viewModel.isAddingToCart)
                        
                        if let cartError = viewModel.addToCartError { /* ... */ }
                        if let cartSuccess = viewModel.addToCartSuccessMessage { /* ... */ }

                        if !product.description.isEmpty { /* ... */ }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.bottom)
            } else {
                Text("").frame(maxWidth: .infinity, minHeight: 300)
            }
        }
        .navigationTitle(viewModel.product?.name ?? "Produktdetail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Die Hauptlogik zum Laden ist jetzt im init des ViewModels.
            // Wenn du ein "Pull-to-Refresh" oder eine explizite Aktualisierung brauchst,
            // würdest du hier viewModel.fetchProductDetails() erneut aufrufen.
            // Für den ersten Load ist es bereits abgedeckt.
            // viewModel.fetchProductDetails() // Entfernt, da im init des VM. Ggf. bei Bedarf wieder hinzufügen.
        }
    }

    // --- Hilfsfunktionen (stripHtml, determineRegularPrice, stockStatusText, stockStatusColor, productImageGallery) ---
    // Diese bleiben im Wesentlichen gleich, aber stelle sicher, dass stockStatusText/Color mit dem StockStatus Enum arbeiten.

    private func stripHtml(from text: String) -> String { /* ... */ }
    
    private func determineRegularPrice(product: WooCommerceProduct, variation: WooCommerceProductVariation?) -> String? { /* ... */ }
    
    private func stockStatusText(product: WooCommerceProduct, variation: WooCommerceProductVariation?) -> String {
        let statusToCheck = variation?.stockStatus ?? product.stockStatus // Ist jetzt vom Typ StockStatus
        switch statusToCheck {
        case .instock: return "Auf Lager"
        case .outofstock: return "Ausverkauft"
        case .onbackorder: return "Lieferbar auf Anfrage"
        }
    }

    private func stockStatusColor(product: WooCommerceProduct, variation: WooCommerceProductVariation?) -> Color {
        let statusToCheck = variation?.stockStatus ?? product.stockStatus // Ist jetzt vom Typ StockStatus
        switch statusToCheck {
        case .instock: return .green
        case .outofstock: return .red
        case .onbackorder: return .orange
        }
    }
    
    @ViewBuilder
    private func productImageGallery(images: [WooCommerceImage], productName: String) -> some View { /* ... */ }
}

// Preview Provider (sollte jetzt funktionieren, da WooCommerceProduct.placeholder angepasst wurde)
struct ProductDetailView_Previews: PreviewProvider { /* ... */ }

// AttributeSelectorView (angepasst, um selectedOptionSlugForThisAttribute entgegenzunehmen)
struct AttributeSelectorView: View {
    let attribute: WooCommerceAttribute
    let variations: [WooCommerceProductVariation]
    let selectedOptionSlugForThisAttribute: String? // Der aktuell ausgewählte Options-SLUG für DIESES Attribut
    let onSelect: (String) -> Void

    private var availableOptionsForAttribute: [(name: String, slug: String)] {
        // Erhalte alle einzigartigen Options-Slugs und -Namen für dieses Attribut
        // aus den existierenden Variationen.
        var uniqueOptions = [String: String]() // slug: name
        for variation in variations {
            for varAttr in variation.attributes {
                if varAttr.name == attribute.name || varAttr.id == attribute.id {
                    let optionSlug = varAttr.slug ?? varAttr.option.lowercased().replacingOccurrences(of: " ", with: "-")
                    if uniqueOptions[optionSlug] == nil {
                        uniqueOptions[optionSlug] = varAttr.option // Speichere den Anzeigenamen
                    }
                }
            }
        }
        // Sortiere nach dem Anzeigenamen für eine konsistente Reihenfolge
        return uniqueOptions.map { (name: $0.value, slug: $0.key) }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(attribute.name):") // Zeige den Namen des Attributs
                .font(.headline)
            // ... (UI für Buttons oder Picker, wie zuvor) ...
            // Beispiel mit Buttons:
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(availableOptionsForAttribute, id: \.slug) { option in
                        Button(action: {
                            onSelect(option.slug)
                        }) {
                            Text(option.name) // Zeige den Options-NAMEN
                                .font(.footnote)
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(selectedOptionSlugForThisAttribute == option.slug ? Color.accentColor : Color(UIColor.systemGray5))
                                .foregroundColor(selectedOptionSlugForThisAttribute == option.slug ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 8)
    }
}
