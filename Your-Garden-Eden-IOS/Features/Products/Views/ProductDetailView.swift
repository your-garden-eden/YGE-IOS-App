// YGE-IOS-App/Features/Products/Views/ProductDetailView.swift
import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @Environment(\.dismiss) var dismiss // Für Zurück-Navigation, falls benötigt

    @State private var selectedImageIndex: Int = 0 // Für die Bildergalerie

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        // StateObject wird hier initialisiert, was korrekt ist für Views, die ihre eigenen VMs besitzen.
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productSlug: productSlug, initialProductData: initialProductData))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { // Haupt-VStack ohne Standard-Spacing
                
                // MARK: - Lade- & Fehlerzustand (wenn kein Produkt geladen ist)
                if viewModel.isLoading && viewModel.product == nil {
                    ProgressView {
                        Text("Lade Produktdetails...")
                            .font(AppFonts.roboto(size: AppFonts.Size.body))
                            .foregroundColor(AppColors.textMuted)
                    }
                    .frame(maxWidth: .infinity, minHeight: 300, alignment: .center)
                    .padding(AppStyles.Spacing.large)
                } else if let errorMessage = viewModel.errorMessage, viewModel.product == nil {
                    VStack(spacing: AppStyles.Spacing.medium) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.error)
                        Text("Fehler beim Laden")
                            .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold))
                            .foregroundColor(AppColors.textHeadings)
                        Text(errorMessage)
                            .font(AppFonts.roboto(size: AppFonts.Size.body))
                            .foregroundColor(AppColors.textMuted)
                            .multilineTextAlignment(.center)
                        Button("Erneut versuchen") {
                            viewModel.fetchProductDetails() // ViewModel-Funktion aufrufen
                        }
                        .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                        .padding(.horizontal, AppStyles.Spacing.large)
                        .padding(.vertical, AppStyles.Spacing.small)
                        .foregroundColor(AppColors.textOnPrimary)
                        .background(AppColors.primary)
                        .cornerRadius(AppStyles.BorderRadius.medium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 300, alignment: .center)
                    .padding(AppStyles.Spacing.large)
                } else if let product = viewModel.product {
                    // MARK: - Produktbildgalerie
                    productImageGallery(
                        images: viewModel.displayImageSet,
                        productName: product.name
                    )
                    .padding(.bottom, AppStyles.Spacing.medium)

                    // MARK: - Hauptinhaltsbereich (unterhalb der Bilder)
                    VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) { // Abstand zwischen den Elementen hier
                        // Produktname
                        Text(product.name)
                            .font(AppFonts.montserrat(size: AppFonts.Size.h2, weight: .bold)) // Großer Titel
                            .foregroundColor(AppColors.textHeadings)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true) // Erlaubt Umbruch

                        // Preisbereich
                        HStack(alignment: .firstTextBaseline, spacing: AppStyles.Spacing.small) {
                            Text(viewModel.displayPrice + (product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? " €"))
                                .font(AppFonts.roboto(size: AppFonts.Size.h3, weight: .bold)) // Großer Preis
                                .foregroundColor(AppColors.primaryDark) // Akzent für Preis
                            
                            if let regularPrice = viewModel.displayRegularPrice {
                                Text(regularPrice + (product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? " €"))
                                    .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .regular))
                                    .strikethrough(true, color: AppColors.textMuted)
                                    .foregroundColor(AppColors.textMuted)
                            }
                            Spacer()
                        }

                        // Kurzbeschreibung
                        if !product.shortDescription.isEmpty {
                            Text(product.shortDescription.strippingHTML())
                                .font(AppFonts.roboto(size: AppFonts.Size.body))
                                .foregroundColor(AppColors.textBase)
                                .lineLimit(nil) // Erlaube mehrere Zeilen
                        }
                        
                        // MARK: - Varianten Auswahl
                        if product.type == .variable && !product.attributes.filter({ $0.variation }).isEmpty {
                            Divider().padding(.vertical, AppStyles.Spacing.small)
                            ForEach(product.attributes.filter { $0.variation }) { attributeDefinition in
                                AttributeSelectorView(
                                    attribute: attributeDefinition,
                                    allProductVariations: viewModel.variations,
                                    currentlySelectedOptionSlugForThisAttribute: viewModel.selectedAttributes[attributeDefinition.slug ?? attributeDefinition.name.lowercased().replacingOccurrences(of: " ", with: "-")],
                                    onOptionSelect: { selectedOptionSlug in
                                        viewModel.selectAttribute(
                                            attributeDefinitionSlug: attributeDefinition.slug ?? attributeDefinition.name.lowercased().replacingOccurrences(of: " ", with: "-"),
                                            optionValueSlug: selectedOptionSlug
                                        )
                                    }
                                )
                            }
                            Divider().padding(.vertical, AppStyles.Spacing.small)
                        }
                        
                        // MARK: - Mengenauswahl
                        QuantitySelectorView(quantity: $viewModel.quantity)
                            .padding(.bottom, AppStyles.Spacing.small)

                        // MARK: - Lagerstatus
                        HStack { // Für bessere Ausrichtung mit möglichem Icon
                            // Optional: Icon für Lagerstatus
                            // Image(systemName: viewModel.displayStockStatus.color == AppColors.inStock ? "checkmark.circle.fill" : (viewModel.displayStockStatus.color == AppColors.warning ? "exclamationmark.triangle.fill" : "xmark.circle.fill"))
                            //    .foregroundColor(viewModel.displayStockStatus.color)
                            Text(viewModel.displayStockStatus.text)
                                .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .medium))
                                .foregroundColor(viewModel.displayStockStatus.color) // Textfarbe
                                .padding(.vertical, AppStyles.Spacing.xSmall)
                                .padding(.horizontal, AppStyles.Spacing.small)
                                .background(viewModel.displayStockStatus.color.opacity(0.15)) // Hintergrund mit gleicher Farbe, aber opak
                                .clipShape(Capsule())
                        }
                        .padding(.bottom, AppStyles.Spacing.medium)
                        
                        // MARK: - In den Warenkorb Button
                        Button(action: viewModel.addToCart) {
                            HStack { // Für Text und Ladeindikator
                                Spacer()
                                if viewModel.isAddingToCart {
                                    ProgressView().tint(AppColors.textOnPrimary)
                                } else {
                                    Text("In den Warenkorb")
                                        .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .semibold))
                                }
                                Spacer()
                            }
                        }
                        .frame(height: 50)
                        .background(viewModel.canPurchase && !viewModel.isAddingToCart ? AppColors.primary : AppColors.textMuted.opacity(0.5)) // Primärfarbe für Button
                        .foregroundColor(AppColors.textOnPrimary)
                        .cornerRadius(AppStyles.BorderRadius.medium)
                        .disabled(!viewModel.canPurchase || viewModel.isAddingToCart)
                        .appShadow(AppStyles.Shadows.small) // Leichter Schatten
                        
                        // Fehlermeldungen für Warenkorb
                        if let cartError = viewModel.addToCartError {
                            Text("Fehler: \(cartError)")
                                .font(AppFonts.roboto(size: AppFonts.Size.caption))
                                .foregroundColor(AppColors.error)
                                .padding(.top, AppStyles.Spacing.xSmall)
                        }
                        if let cartSuccess = viewModel.addToCartSuccessMessage {
                             Text(cartSuccess)
                                .font(AppFonts.roboto(size: AppFonts.Size.caption))
                                .foregroundColor(AppColors.success) // Erfolgsfarbe
                                .padding(.top, AppStyles.Spacing.xSmall)
                        }

                        // MARK: - Lange Produktbeschreibung
                        if !product.description.isEmpty {
                            Divider().padding(.vertical, AppStyles.Spacing.medium)
                            Text("Produktbeschreibung")
                                .font(AppFonts.montserrat(size: AppFonts.Size.title3, weight: .semibold))
                                .foregroundColor(AppColors.textHeadings)
                                .padding(.bottom, AppStyles.Spacing.xSmall)
                            Text(product.description.strippingHTML()) // strippingHTML sollte schon vorhanden sein
                                .font(AppFonts.roboto(size: AppFonts.Size.body))
                                .foregroundColor(AppColors.textBase)
                                .lineLimit(nil) // Erlaube mehrere Zeilen
                        }
                    }
                    .padding(.horizontal, AppStyles.Spacing.medium) // Seitenabstand für den Hauptinhalt
                    .padding(.bottom, AppStyles.Spacing.large) // Abstand am Ende des Inhalts
                    
                } else {
                    // Fallback, falls product aus irgendeinem Grund nil ist, aber kein Fehler und nicht isLoading
                    Text("Keine Produktdaten verfügbar. Bitte versuchen Sie es später erneut.")
                        .font(AppFonts.roboto(size: AppFonts.Size.body))
                        .foregroundColor(AppColors.textMuted)
                        .frame(maxWidth: .infinity, minHeight: 300, alignment: .center)
                        .padding(AppStyles.Spacing.large)
                }
            }
        }
        .background(AppColors.backgroundPage.ignoresSafeArea()) // Hintergrund für die gesamte View
        .navigationTitle(viewModel.product?.name ?? "Produktdetail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.backgroundPage.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        // .onAppear wird nicht mehr benötigt, da der Load im init des ViewModels stattfindet
    }
    
    // MARK: - Subviews (wie productImageGallery)
    @ViewBuilder
    private func productImageGallery(images: [WooCommerceImage], productName: String) -> some View {
        Group { // Group für bedingte Inhalte
            if !images.isEmpty {
                TabView(selection: $selectedImageIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        AsyncImage(url: URL(string: images[index].src)) { imagePhase in
                            switch imagePhase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Zentrieren
                            case .success(let image):
                                image.resizable()
                                     .aspectRatio(contentMode: .fit) // .fit, um das ganze Bild zu sehen
                            case .failure:
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50)) // Größeres Placeholder-Icon
                                    .foregroundColor(AppColors.textMuted.opacity(0.7))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .tag(index)
                        .accessibilityLabel("Produktbild \(index + 1) von \(productName)")
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Index-Punkte entfernen oder .automatic
                .frame(height: 300) // Höhe anpassen nach Bedarf
                .background(AppColors.backgroundComponent) // Hintergrund für den TabView-Bereich
                .overlay(alignment: .bottom) { // Eigene Paginierung, wenn gewünscht
                    if images.count > 1 {
                        HStack(spacing: AppStyles.Spacing.small) {
                            ForEach(images.indices, id: \.self) { index in
                                Circle()
                                    .fill(selectedImageIndex == index ? AppColors.primary : AppColors.textMuted.opacity(0.5))
                                    .frame(width: 8, height: 8)
                                    .onTapGesture { selectedImageIndex = index } // Klickbare Punkte
                            }
                        }
                        .padding(.bottom, AppStyles.Spacing.small)
                    }
                }
            } else { // Fallback, wenn keine Bilder vorhanden sind
                ZStack {
                    AppColors.backgroundLightGray // Heller Hintergrund für den Placeholder
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100) // Größe des Placeholder-Icons
                        .foregroundColor(AppColors.textMuted.opacity(0.7))
                }
                .frame(height: 300) // Gleiche Höhe wie die Galerie
            }
        }
    }
}

