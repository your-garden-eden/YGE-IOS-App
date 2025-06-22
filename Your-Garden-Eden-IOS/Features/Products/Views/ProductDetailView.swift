// DATEI: ProductDetailView.swift
// PFAD: Features/Products/Views/Detail/ProductDetailView.swift
// VERSION: KLARHEIT 1.1 (VOLLSTÄNDIG & KORRIGIERT)

import SwiftUI

struct ProductDetailView: View {
    let product: WooCommerceProduct
    
    @StateObject private var viewModel = ProductDetailViewModel()
    @EnvironmentObject var wishlistState: WishlistState
    @EnvironmentObject var cartManager: CartAPIManager
    
    @State private var selectedQuantity: Int = 1
    @State private var showAddedToCartConfirmation = false

    // Eine berechnete Eigenschaft für Klarheit und zur Vermeidung von Wiederholungen.
    private var isProductPurchasable: Bool {
        // KORREKTUR: Die Logik wurde angepasst, um nil als 'nicht kaufbar' zu behandeln.
        product.purchasable == true
    }

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
                    
                    recommendedSection
                    
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
        .customBackButton()
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
    
    @ViewBuilder
    private var productGallery: some View {
        ZStack {
            if product.safeImages.count > 1 {
                TabView {
                    ForEach(product.safeImages) { image in
                        AsyncImage(url: image.src.asURL()) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFit()
                            case .failure:
                                Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppTheme.Colors.textMuted)
                            default:
                                ShimmerView()
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 300)
            } else {
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
            
            // --- BEGINN KORREKTUR ---
            // Nutzt nun die gehärtete 'isProductPurchasable'-Eigenschaft.
            if !isProductPurchasable {
                notAvailableOverlay
            }
            // --- ENDE KORREKTUR ---
        }
    }
    
    @ViewBuilder
    private var productHeader: some View {
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
    
    @ViewBuilder
    private var descriptionSection: some View {
        if let desc = product.description, !desc.isEmpty {
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) {
                Text("Beschreibung").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h6, weight: .semibold))
                ExpandableTextView(text: desc, lineLimit: 2)
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private var recommendedSection: some View {
        if viewModel.isLoadingRecommendations {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical)
        } else if !viewModel.recommendedProducts.isEmpty {
            VStack {
                Divider().padding(.horizontal)
                RelatedProductsView(
                    title: "Das könnte Ihnen auch gefallen",
                    products: viewModel.recommendedProducts
                )
            }
        }
    }
    
    @ViewBuilder
    private var bottomActionSection: some View {
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

    @ViewBuilder
    private var simpleProductActions: some View {
        if product.sold_individually == false {
            QuantitySelectorView(quantity: $selectedQuantity)
                .padding(.horizontal)
                .disabled(!isProductPurchasable)
        }
        
        Button(action: {
            Task {
                await cartManager.addItem(productId: product.id, quantity: selectedQuantity)
            }
        }) {
            HStack {
                if cartManager.state.isLoading { ProgressView().tint(.white) }
                else if !isProductPurchasable || product.stock_status != .instock { Text("Nicht verfügbar") }
                else { Text("In den Warenkorb") }
            }
        }
        .buttonStyle(AppTheme.PrimaryButtonStyle())
        .disabled(cartManager.state.isLoading || !isProductPurchasable || product.stock_status != .instock)
    }

    @ViewBuilder
    private var variableProductActions: some View {
        let isNavigationDisabled = !isProductPurchasable || viewModel.isLoadingVariations || viewModel.variationError != nil || viewModel.variations.isEmpty
        
        NavigationLink(value: ProductVariationData(product: product, variations: viewModel.variations)) {
            if viewModel.isLoadingVariations { ProgressView().tint(.white) }
            else if !isProductPurchasable { Text("Nicht verfügbar") }
            else { Text("Optionen auswählen") }
        }
        .buttonStyle(AppTheme.PrimaryButtonStyle())
        .disabled(isNavigationDisabled)
    }
    
    @ViewBuilder
    private var confirmationBanner: some View {
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

    @ViewBuilder
    private var notAvailableOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)

            Text("Nicht verfügbar")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h5, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Layout.Spacing.medium)
                .padding(.vertical, AppTheme.Layout.Spacing.small)
                .background(Color.black.opacity(0.4))
                .cornerRadius(AppTheme.Layout.BorderRadius.large)
        }
    }
}
