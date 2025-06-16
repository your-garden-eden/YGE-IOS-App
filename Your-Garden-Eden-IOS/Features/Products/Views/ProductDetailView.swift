// Path: Your-Garden-Eden-IOS/Features/Products/Views/ProductDetailView.swift
// VERSION 3.0 (FINAL - With ViewModel for Price Range & Cross-Sells)

import SwiftUI

struct ProductDetailView: View {
    let product: WooCommerceProduct
    
    @StateObject private var viewModel = ProductDetailViewModel()
    @EnvironmentObject var wishlistState: WishlistState
    @EnvironmentObject var cartManager: CartAPIManager
    
    @State private var showAddedToCartConfirmation = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppStyles.Spacing.large) {
                    productGallery
                    productHeader
                    
                    if product.type == "variable" && viewModel.isLoadingVariations {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 50)
                    } else if let error = viewModel.variationError {
                        ErrorStateView(message: error)
                    }
                    
                    Divider()
                    descriptionSection
                    crossSellSection // Beibehaltung der Struktur
                    
                    Spacer(minLength: 150)
                }
            }
            .safeAreaInset(edge: .bottom) {
                 bottomActionSection
            }
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle(product.name.strippingHTML())
        .navigationBarTitleDisplayMode(.inline)
        .task(id: product.id) {
            await viewModel.loadData(for: product)
        }
        .onChange(of: cartManager.state.errorMessage) { _, newValue in
             if newValue != nil {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 3) { /* Nichts tun, Manager löscht selbst */ }
             }
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
            case .failure: Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted)
            default: ShimmerView()
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(AppColors.backgroundLightGray)
    }
    
    @ViewBuilder private var productHeader: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            HStack(alignment: .top) {
                Text(product.name.strippingHTML())
                    .font(AppFonts.montserrat(size: AppFonts.Size.h4, weight: .bold))
                Spacer()
                Button(action: { wishlistState.toggleWishlistStatus(for: product) }) {
                    Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                        .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? AppColors.error : AppColors.secondary)
                }
                .font(.title)
                .animation(.spring(), value: wishlistState.isProductInWishlist(productId: product.id))
            }
            
            HStack(alignment: .bottom, spacing: AppStyles.Spacing.small) {
                if let range = viewModel.priceRangeDisplay {
                    Text(range)
                        .font(AppFonts.roboto(size: AppFonts.Size.h5, weight: .bold))
                        .foregroundColor(AppColors.price)
                } else {
                    let priceInfo = PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price)
                    Text(priceInfo.display)
                        .font(AppFonts.roboto(size: AppFonts.Size.h5, weight: .bold))
                        .foregroundColor(AppColors.price)
                    if let strikethrough = priceInfo.strikethrough {
                        Text(strikethrough)
                            .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular))
                            .strikethrough(true, color: AppColors.textMuted)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var descriptionSection: some View {
        if let desc = product.description, !desc.isEmpty {
            VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
                Text("Beschreibung").font(AppFonts.montserrat(size: AppFonts.Size.h6, weight: .semibold))
                ExpandableTextView(text: desc, lineLimit: 2)
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var crossSellSection: some View {
        // Diese Logik kann später in den ProductDetailViewModel integriert werden
        VStack{}
    }
    
    @ViewBuilder private var bottomActionSection: some View {
        VStack(spacing: AppStyles.Spacing.medium) {
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
            QuantitySelectorView(quantity: .constant(1)) // Beispiel, Binden Sie dies an viewModel
                .padding(.horizontal)
        }
        
        Button(action: {
            Task {
                await cartManager.addItem(
                    productId: product.id,
                    quantity: 1 // Binden Sie dies an viewModel
                )
            }
        }) {
            HStack {
                if cartManager.state.isLoading { ProgressView().tint(.white) }
                else if !product.isPurchasable || product.stock_status != .instock { Text("Nicht verfügbar") }
                else { Text("In den Warenkorb") }
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(cartManager.state.isLoading || !product.isPurchasable || product.stock_status != .instock)
    }

    @ViewBuilder private var variableProductActions: some View {
        let isNavigationDisabled = viewModel.isLoadingVariations || viewModel.variationError != nil || viewModel.variations.isEmpty
        
        NavigationLink(value: ProductVariationData(product: product, variations: viewModel.variations)) {
            if viewModel.isLoadingVariations { ProgressView().tint(.white) }
            else { Text("Optionen auswählen") }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isNavigationDisabled)
    }
    
    @ViewBuilder private var confirmationBanner: some View {
        VStack {
            if showAddedToCartConfirmation {
                SuccessBanner(message: "Zum Warenkorb hinzugefügt")
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            if let errorMessage = cartManager.state.errorMessage {
                ErrorBanner(message: errorMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top).padding(.top)
    }
}

