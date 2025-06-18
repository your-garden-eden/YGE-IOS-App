// DATEI: ProductOptionsView.swift
// PFAD: Features/Products/Views/Options/ProductOptionsView.swift
// ZWECK: Die Hauptansicht zur Auswahl von Optionen (Variationen) für ein variables Produkt.

import SwiftUI

struct ProductOptionsView: View {
    
    @StateObject private var viewModel: ProductOptionsViewModel
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartManager: CartAPIManager
    
    @State private var selectedImageID: Int?

    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        _viewModel = StateObject(wrappedValue: ProductOptionsViewModel(
            product: product,
            variations: variations
        ))
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
                .padding(.bottom, 160)
            }
            .safeAreaInset(edge: .bottom) {
                addToCartSection
            }
        }
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Optionen auswählen")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .onAppear {
            self.selectedImageID = viewModel.product.safeImages.first?.id
        }
        .onChange(of: viewModel.currentImage) { _, newImage in
            withAnimation(.easeInOut) {
                self.selectedImageID = newImage?.id
            }
        }
        .onChange(of: cartManager.state.items) {
            if cartManager.state.errorMessage == nil {
                dismiss()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var gallerySection: some View {
        VStack(spacing: AppTheme.Layout.Spacing.small) {
            AsyncImage(url: (viewModel.currentImage ?? viewModel.product.safeImages.first)?.src.asURL()) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                default:
                    Rectangle()
                        .fill(AppTheme.Colors.backgroundLightGray)
                        .overlay(ProgressView().tint(AppTheme.Colors.primary))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 300)
            
            if viewModel.product.safeImages.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.product.safeImages) { image in
                            Button(action: {
                                withAnimation {
                                    self.selectedImageID = image.id
                                }
                            }) {
                                AsyncImage(url: image.src.asURL()) { phase in
                                    switch phase {
                                    case .success(let thumb):
                                        thumb.resizable().scaledToFill()
                                    default:
                                        Rectangle().fill(AppTheme.Colors.borderLight)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(AppTheme.Layout.BorderRadius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Layout.BorderRadius.medium)
                                        .stroke(selectedImageID == image.id ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) {
            Text(viewModel.product.name.strippingHTML())
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h4, weight: .bold))
            
            let priceInfo = viewModel.displayPrice
            Text(priceInfo.display)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.h3, weight: .bold))
                .foregroundColor(AppTheme.Colors.price)
        }
        .padding(.horizontal)
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
        }
        .padding(.horizontal)
    }
    
    private var addToCartSection: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            Text(viewModel.stockStatusMessage.text)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .bold))
                .foregroundColor(viewModel.stockStatusMessage.color)
                .animation(.easeInOut, value: viewModel.stockStatusMessage.text)
            
            Button(action: { Task { await viewModel.handleAddToCart() } }) {
                if cartManager.state.isLoading { ProgressView().tint(.white) }
                else {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("In den Warenkorb")
                    }
                }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(viewModel.isAddToCartDisabled)
            
            if let error = cartManager.state.errorMessage ?? viewModel.addToCartError {
                Text(error)
                    .font(.caption).foregroundColor(.red).multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}
