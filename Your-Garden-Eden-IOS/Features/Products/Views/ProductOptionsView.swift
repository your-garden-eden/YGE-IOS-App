// DATEI: ProductOptionsView.swift
// PFAD: Features/Products/Views/Options/ProductOptionsView.swift
// VERSION: 1.3 (REPARIERT & AUFGETEILT)
// STATUS: Einsatzbereit.

import SwiftUI

struct ProductOptionsView: View {
    
    @StateObject private var viewModel: ProductOptionsViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartManager: CartAPIManager
    
    @State private var selectedImageID: Int?

    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        _viewModel = StateObject(wrappedValue: ProductOptionsViewModel(product: product, variations: variations))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xLarge) {
                    gallerySection
                    headerSection
                    Divider()
                    attributesSection
                }
                .padding(.bottom, 180) // Etwas mehr Platz für den Button
            }
            .safeAreaInset(edge: .bottom) {
                // Die Hauptkomponente ruft jetzt nur noch die Unterkomponenten auf.
                addToCartSection
            }
        }
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Optionen auswählen").navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .onAppear { self.selectedImageID = viewModel.product.safeImages.first?.id }
        .onChange(of: viewModel.currentImage) { _, newImage in
            withAnimation(.easeInOut) { self.selectedImageID = newImage?.id }
        }
        .onChange(of: cartManager.state.items) {
            if cartManager.state.errorMessage == nil && !cartManager.state.isLoading { dismiss() }
        }
    }
    
    private var gallerySection: some View {
        VStack(spacing: AppTheme.Layout.Spacing.small) {
            AsyncImage(url: (viewModel.currentImage ?? viewModel.product.safeImages.first)?.src.asURL()) { phase in
                if let image = phase.image { image.resizable().scaledToFit() }
                else { Rectangle().fill(AppTheme.Colors.backgroundLightGray).overlay(ProgressView()) }
            }.frame(maxWidth: .infinity, minHeight: 300)
            
            if viewModel.product.safeImages.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.product.safeImages) { image in
                            Button(action: { withAnimation { self.selectedImageID = image.id } }) {
                                AsyncImage(url: image.src.asURL()) { phase in
                                    if let thumb = phase.image { thumb.resizable().scaledToFill() }
                                    else { Rectangle().fill(AppTheme.Colors.borderLight) }
                                }
                                .frame(width: 60, height: 60).clipped().cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(selectedImageID == image.id ? AppTheme.Colors.primary : .clear, lineWidth: 2))
                            }
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) {
            Text(viewModel.product.name.strippingHTML()).font(AppTheme.Fonts.montserrat(size: 24, weight: .bold))
            let priceInfo = viewModel.displayPrice
            Text(priceInfo.display).font(AppTheme.Fonts.roboto(size: 28, weight: .bold)).foregroundColor(AppTheme.Colors.price)
        }.padding(.horizontal)
    }
    
    private var attributesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.large) {
            ForEach(viewModel.displayableAttributes) { attribute in
                AttributeSelectorView(
                    attribute: attribute,
                    availableOptionSlugs: viewModel.availability[attribute.slug] ?? [],
                    selectedOptionSlug: viewModel.selectedAttributes[attribute.slug],
                    onSelect: { optionSlug in
                        viewModel.select(attributeSlug: attribute.slug, optionSlug: optionSlug)
                    }
                )
            }
        }.padding(.horizontal)
    }
    
    // ===================================================================
    // === BEGINN KORREKTUR #17                                        ===
    // ===================================================================
    // ANGEPASST: Die Hauptkomponente wird entschlackt.
    private var addToCartSection: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            stockStatusText
            addToCartButton
            errorText
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }

    // HINZUGEFÜGT: Kleinere, fokussierte Unter-Komponente.
    @ViewBuilder
    private var stockStatusText: some View {
        Text(viewModel.stockStatusMessage.text)
            .font(AppTheme.Fonts.roboto(size: 16, weight: .bold))
            .foregroundColor(viewModel.stockStatusMessage.color)
            .animation(.easeInOut, value: viewModel.stockStatusMessage.text)
    }

    // HINZUGEFÜGT: Kleinere, fokussierte Unter-Komponente.
    @ViewBuilder
    private var addToCartButton: some View {
        Button(action: { Task { await viewModel.handleAddToCart() } }) {
            if cartManager.state.isLoading {
                ProgressView().tint(.white)
            } else {
                HStack {
                    Image(systemName: "cart.fill")
                    Text("In den Warenkorb")
                }
            }
        }
        .buttonStyle(AppTheme.PrimaryButtonStyle())
        .disabled(viewModel.isAddToCartDisabled)
    }

    // HINZUGEFÜGT: Kleinere, fokussierte Unter-Komponente.
    @ViewBuilder
    private var errorText: some View {
        if let error = cartManager.state.errorMessage ?? viewModel.addToCartError {
            Text(error)
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }
    // ===================================================================
    // === ENDE KORREKTUR #17                                          ===
    // ===================================================================
}
