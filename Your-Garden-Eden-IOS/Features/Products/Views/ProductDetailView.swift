// DATEI: ProductDetailView.swift
// PFAD: Features/Products/Views/Detail/ProductDetailView.swift
// VERSION: 3.3 (FINAL & ANGEPASST)

import SwiftUI

struct ProductDetailView: View {
    let product: WooCommerceProduct
    
    @StateObject private var viewModel = ProductDetailViewModel()
    @EnvironmentObject var wishlistState: WishlistState
    @EnvironmentObject var cartManager: CartAPIManager
    
    @State private var showAddedToCartConfirmation = false

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.large) {
                    productGallery
                    productHeader
                    
                    if product.type == "variable" && viewModel.isLoadingVariations {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 50)
                    } else if let error = viewModel.variationError {
                        StatusIndicatorView.errorState(message: error)
                    }
                    
                    Divider()
                    descriptionSection
                    
                    Spacer(minLength: 150)
                }
            }
            .safeAreaInset(edge: .bottom) {
                 bottomActionSection
            }
            
            confirmationBanner
        }
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle(product.name.strippingHTML())
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton() // <-- BEFEHL HINZUGEFÜGT
        .task(id: product.id) {
            await viewModel.loadData(for: product)
        }
        .onChange(of: cartManager.state.items) { _, _ in
             if cartManager.state.errorMessage == nil {
                 withAnimation { showAddedToCartConfirmation = true }
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                     withAnimation { showAddedToCartConfirmation = false }
                 }
             }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder private var productGallery: some View {
        AsyncImage(url: product.safeImages.first?.src.asURL()) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFit()
            case .failure: Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppTheme.Colors.textMuted)
            default: ShimmerView()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(AppTheme.Colors.backgroundLightGray)
    }
    
    @ViewBuilder private var productHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) {
            HStack(alignment: .top) {
                Text(product.name.strippingHTML())
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h4, weight: .bold))
                Spacer()
                Button(action: { wishlistState.toggleWishlistStatus(for: product) }) {
                    Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                        .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? AppTheme.Colors.error : AppTheme.Colors.secondary)
                }
                .font(.title)
                .animation(.spring(), value: wishlistState.isProductInWishlist(productId: product.id))
            }
            
            HStack(alignment: .bottom, spacing: AppTheme.Layout.Spacing.small) {
                if let range = viewModel.priceRangeDisplay {
                    Text(range)
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.h5, weight: .bold))
                        .foregroundColor(AppTheme.Colors.price)
                } else {
                    let priceInfo = PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price)
                    Text(priceInfo.display)
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.h5, weight: .bold))
                        .foregroundColor(AppTheme.Colors.price)
                    if let strikethrough = priceInfo.strikethrough {
                        Text(strikethrough)
                            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .regular))
                            .strikethrough(true, color: AppTheme.Colors.textMuted)
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var descriptionSection: some View {
        if let desc = product.description, !desc.isEmpty {
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) {
                Text("Beschreibung").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h6, weight: .semibold))
                ExpandableTextView(text: desc, lineLimit: 2)
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder private var bottomActionSection: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            if product.type == "simple" {
                simpleProductActions
            } else if product.type == "variable" {
                variableProductActions
            }
        }
        .padding()
        .background(.regularMaterial)
    }

    @ViewBuilder private var simpleProductActions: some View {
        if product.sold_individually == false {
            QuantitySelectorView(quantity: .constant(1))
                .padding(.horizontal)
        }
        
        Button(action: {
            Task {
                await cartManager.addItem(productId: product.id, quantity: 1)
            }
        }) {
            HStack {
                if cartManager.state.isLoading { ProgressView().tint(.white) }
                else if !product.isPurchasable || product.stock_status != .instock { Text("Nicht verfügbar") }
                else { Text("In den Warenkorb") }
            }
        }
        .buttonStyle(AppTheme.PrimaryButtonStyle())
        .disabled(cartManager.state.isLoading || !product.isPurchasable || product.stock_status != .instock)
    }

    @ViewBuilder private var variableProductActions: some View {
        let isNavigationDisabled = viewModel.isLoadingVariations || viewModel.variationError != nil || viewModel.variations.isEmpty
        
        NavigationLink(value: ProductVariationData(product: product, variations: viewModel.variations)) {
            if viewModel.isLoadingVariations { ProgressView().tint(.white) }
            else { Text("Optionen auswählen") }
        }
        .buttonStyle(AppTheme.PrimaryButtonStyle())
        .disabled(isNavigationDisabled)
    }
    
    @ViewBuilder private var confirmationBanner: some View {
        VStack {
            if showAddedToCartConfirmation {
                StatusIndicatorView.successBanner(message: "Zum Warenkorb hinzugefügt")
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            if let errorMessage = cartManager.state.errorMessage {
                StatusIndicatorView.errorBanner(message: errorMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top).padding(.top)
        .animation(.default, value: showAddedToCartConfirmation)
        .animation(.default, value: cartManager.state.errorMessage)
    }
}
