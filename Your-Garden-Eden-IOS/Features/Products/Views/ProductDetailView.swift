// Features/Products/Views/ProductDetailView.swift
import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var wishlistState: WishlistState // Für die Wunschlisten-Funktion
    // authManager wird nicht mehr direkt für das Herz benötigt, aber falls andere Aktionen es brauchen:
    // @EnvironmentObject var authManager: FirebaseAuthManager

    @StateObject private var viewModel: ProductDetailViewModel // ViewModel für Produktdaten und -logik
    @Environment(\.dismiss) var dismiss // Um die View ggf. programmatisch zu schließen
    @State private var selectedImageIndex: Int = 0 // Für die Bildergalerie

    // showingAuthSheet wird nicht mehr für das Herz-Icon benötigt.
    // Falls du es für andere Aktionen (z.B. "Bewertung schreiben" für nicht-angemeldete User) brauchst, kannst du es behalten.
    // @State private var showingAuthSheet = false

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        // StateObject wird hier korrekt im init initialisiert.
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productSlug: productSlug, initialProductData: initialProductData))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { // Haupt-VStack ohne Standard-Spacing
                
                // MARK: - Lade- & Fehlerzustand (wenn das Hauptprodukt noch nicht geladen ist)
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
                            viewModel.fetchProductDetails()
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
                } else if let product = viewModel.product { // Wenn das Produkt geladen wurde
                    // MARK: - Produktbildgalerie
                    productImageGallery(
                        images: viewModel.displayImageSet, // Verwendet Bilder von Produkt oder ausgewählter Variation
                        productName: product.name
                    )
                    .padding(.bottom, AppStyles.Spacing.medium)

                    // MARK: - Hauptinhaltsbereich (unterhalb der Bilder)
                    VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                        // Produktname und Wunschlisten-Herz
                        HStack(alignment: .top) {
                            Text(product.name)
                                .font(AppFonts.montserrat(size: AppFonts.Size.h2, weight: .bold))
                                .foregroundColor(AppColors.textHeadings)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true) // Erlaubt Umbruch
                            
                            Spacer()

                            Button {
                                // toggleWishlistStatus kümmert sich um lokale/Online-Speicherung
                                wishlistState.toggleWishlistStatus(for: product.id)
                            } label: {
                                Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                                    .font(.title) // Passende Größe für Detailansicht
                                    .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? AppColors.wishlistIcon : AppColors.textMuted)
                                    .padding(AppStyles.Spacing.xSmall) // Klickbereich
                            }
                        }

                        // Preisbereich
                        HStack(alignment: .firstTextBaseline, spacing: AppStyles.Spacing.small) {
                            Text(viewModel.displayPrice + (product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? AppConfig.WooCommerce.defaultCurrencySymbol))
                                .font(AppFonts.roboto(size: AppFonts.Size.h3, weight: .bold))
                                .foregroundColor(AppColors.primaryDark)
                            
                            if let regularPrice = viewModel.displayRegularPrice {
                                Text(regularPrice + (product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? AppConfig.WooCommerce.defaultCurrencySymbol))
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
                                .lineLimit(nil)
                        }
                        
                        // Varianten Auswahl
                        if product.type == .variable && !product.attributes.filter({ $0.variation }).isEmpty {
                            Divider().padding(.vertical, AppStyles.Spacing.small)
                            ForEach(product.attributes.filter { $0.variation }) { attributeDefinition in
                                AttributeSelectorView(
                                    attribute: attributeDefinition,
                                    allProductVariations: viewModel.variations,
                                    currentlySelectedOptionSlugForThisAttribute: viewModel.selectedAttributes[attributeDefinition.slugOrNameAsSlug()],
                                    onOptionSelect: { selectedOptionSlug in
                                        viewModel.selectAttribute(
                                            attributeDefinitionSlug: attributeDefinition.slugOrNameAsSlug(),
                                            optionValueSlug: selectedOptionSlug
                                        )
                                    }
                                )
                            }
                            Divider().padding(.vertical, AppStyles.Spacing.small)
                        }
                        
                        // Mengenauswahl
                        QuantitySelectorView(quantity: $viewModel.quantity)
                            .padding(.bottom, AppStyles.Spacing.small)

                        // Lagerstatus
                        HStack {
                            Text(viewModel.displayStockStatus.text)
                                .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .medium))
                                .foregroundColor(viewModel.displayStockStatus.color)
                                .padding(.vertical, AppStyles.Spacing.xSmall)
                                .padding(.horizontal, AppStyles.Spacing.small)
                                .background(viewModel.displayStockStatus.color.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .padding(.bottom, AppStyles.Spacing.medium)
                        
                        // In den Warenkorb Button
                        Button(action: viewModel.addToCart) {
                            HStack {
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
                        .background(viewModel.canPurchase && !viewModel.isAddingToCart ? AppColors.primary : AppColors.textMuted.opacity(0.5))
                        .foregroundColor(AppColors.textOnPrimary)
                        .cornerRadius(AppStyles.BorderRadius.medium)
                        .disabled(!viewModel.canPurchase || viewModel.isAddingToCart)
                        .appShadow(AppStyles.Shadows.small)
                        
                        // Fehlermeldungen/Erfolgsmeldungen für Warenkorb-Aktion
                        if let cartError = viewModel.addToCartError {
                            Text("Fehler: \(cartError)")
                                .font(AppFonts.roboto(size: AppFonts.Size.caption))
                                .foregroundColor(AppColors.error)
                                .padding(.top, AppStyles.Spacing.xSmall)
                        }
                        if let cartSuccess = viewModel.addToCartSuccessMessage {
                             Text(cartSuccess)
                                .font(AppFonts.roboto(size: AppFonts.Size.caption))
                                .foregroundColor(AppColors.success)
                                .padding(.top, AppStyles.Spacing.xSmall)
                        }

                        // Lange Produktbeschreibung
                        if !product.description.isEmpty {
                            Divider().padding(.vertical, AppStyles.Spacing.medium)
                            Text("Produktbeschreibung")
                                .font(AppFonts.montserrat(size: AppFonts.Size.title3, weight: .semibold))
                                .foregroundColor(AppColors.textHeadings)
                                .padding(.bottom, AppStyles.Spacing.xSmall)
                            Text(product.description.strippingHTML())
                                .font(AppFonts.roboto(size: AppFonts.Size.body))
                                .foregroundColor(AppColors.textBase)
                                .lineLimit(nil)
                        }
                    }
                    .padding(.horizontal, AppStyles.Spacing.medium)
                    .padding(.bottom, AppStyles.Spacing.large)
                    
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
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle(viewModel.product?.name ?? "Produktdetail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.backgroundPage.opacity(0.8), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        // .sheet(isPresented: $showingAuthSheet) { ... } // Entfernt, da Login nicht mehr für Herz erzwungen wird
    }
    
    // MARK: - Subview für Produktbildgalerie
    @ViewBuilder
    private func productImageGallery(images: [WooCommerceImage], productName: String) -> some View {
        Group {
            if !images.isEmpty {
                TabView(selection: $selectedImageIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        AsyncImage(url: URL(string: images[index].src)) { imagePhase in
                            switch imagePhase {
                            case .empty:
                                ProgressView().tint(AppColors.primary)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppColors.textMuted.opacity(0.7))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            @unknown default: EmptyView()
                            }
                        }
                        .tag(index)
                        .accessibilityLabel("Produktbild \(index + 1) von \(productName)")
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 300) // Anpassen nach Bedarf
                .background(AppColors.backgroundComponent)
                .overlay(alignment: .bottom) {
                    if images.count > 1 {
                        HStack(spacing: AppStyles.Spacing.small) {
                            ForEach(images.indices, id: \.self) { index in
                                Circle()
                                    .fill(selectedImageIndex == index ? AppColors.primary : AppColors.textMuted.opacity(0.5))
                                    .frame(width: 8, height: 8)
                                    .onTapGesture { selectedImageIndex = index }
                            }
                        }
                        .padding(.bottom, AppStyles.Spacing.small)
                    }
                }
            } else {
                ZStack {
                    AppColors.backgroundLightGray
                    Image(systemName: "photo.artframe")
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(AppColors.textMuted.opacity(0.7))
                }
                .frame(height: 300)
            }
        }
    }
}

