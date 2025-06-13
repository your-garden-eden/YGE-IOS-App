// Dateiname: Features/Products/Views/ProductDetailView.swift

import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    
    // KORREKTUR: Wir entfernen den EnvironmentObject für den CartAPIManager.
    // @EnvironmentObject var cartAPIManager: CartAPIManager <-- DIESE ZEILE IST ENTFERNT
    
    // WishlistState ist kein Singleton und wird korrekt über die Environment empfangen.
    @EnvironmentObject var wishlistState: WishlistState
    
    @State private var showAddedToCartConfirmation = false
    @State private var cartErrorBannerMessage: String?

    init(product: WooCommerceProduct) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppStyles.Spacing.xLarge) {
                    productGallery
                    productHeader
                    
                    if viewModel.effectiveProductType == "variable" {
                        if viewModel.isLoading {
                            ProgressView().frame(height: 50)
                        } else if let error = viewModel.loadingError {
                            Text(error).foregroundColor(AppColors.error).padding()
                        }
                    }
                    
                    Divider()
                    descriptionSection
                    
                    Spacer(minLength: 150)
                }
            }
            
            bottomActionSection
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle(viewModel.productName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadVariationsIfNeeded()
        }
        .task {
            await viewModel.prepareDisplayData()
        }
        .overlay(confirmationOrErrorBanners)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder private var productGallery: some View {
        AsyncImage(url: viewModel.product.images.first?.src.asURL()) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFit()
            case .failure: Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted)
            default: ProgressView()
            }
        }
        .frame(minHeight: 300)
        .background(AppColors.backgroundComponent)
    }
    
    @ViewBuilder private var productHeader: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            HStack(alignment: .top) {
                Text(viewModel.productName)
                    .font(AppFonts.montserrat(size: AppFonts.Size.title1, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
                Spacer()
                Button(action: { wishlistState.toggleWishlistStatus(for: viewModel.product) }) {
                    Image(systemName: wishlistState.isProductInWishlist(productId: viewModel.product.id) ? "heart.fill" : "heart")
                        .foregroundColor(AppColors.wishlistIcon)
                }
                .font(.title)
                .animation(.spring(), value: wishlistState.isProductInWishlist(productId: viewModel.product.id))
            }
            
            Text(viewModel.initialDisplayPrice)
                .font(AppFonts.roboto(size: AppFonts.Size.title2, weight: .semibold))
                .foregroundColor(AppColors.price)
                .frame(minHeight: 20)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            Text("Beschreibung").font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            
            if !viewModel.productDescription.isEmpty {
                // Hier sollte Ihre ExpandableText-View stehen.
                // Wenn sie nicht existiert, können Sie vorübergehend Text() verwenden.
                Text(viewModel.productDescription)
                    .font(AppFonts.roboto(size: AppFonts.Size.body))
                    .lineLimit(4) // Beispiel
            } else {
                ProgressView().padding(.vertical)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var bottomActionSection: some View {
        VStack(spacing: 12) {
            if viewModel.effectiveProductType == "simple" {
                if !viewModel.product.soldIndividually {
                    // Hier sollte Ihre QuantitySelectorView stehen.
                    QuantitySelectorView(quantity: $viewModel.quantity)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await viewModel.addSimpleProductToCart()
                        
                        // KORREKTUR: Wir greifen jetzt direkt auf den Singleton zu.
                        if CartAPIManager.shared.errorMessage == nil {
                            withAnimation { showAddedToCartConfirmation = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showAddedToCartConfirmation = false }
                            }
                        } else {
                            cartErrorBannerMessage = CartAPIManager.shared.errorMessage
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation { cartErrorBannerMessage = nil }
                            }
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isAddingToCart { ProgressView().tint(.white) }
                        else { Text("In den Warenkorb") }
                    }
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .bold))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
                .controlSize(.large)
                .disabled(viewModel.isAddingToCart)
            
            } else if viewModel.effectiveProductType == "variable" {
                let isNavigationDisabled = viewModel.variations.isEmpty && viewModel.isLoading
                
                NavigationLink(value: ProductVariationData(product: viewModel.product, variations: viewModel.variations)) {
                    Text("Optionen wählen")
                        .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .bold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
                .controlSize(.large)
                .disabled(isNavigationDisabled)
            }
        }
        .padding()
        .background(.thinMaterial)
    }
    
    @ViewBuilder private var confirmationOrErrorBanners: some View {
        VStack {
            if showAddedToCartConfirmation {
                Text("Zum Warenkorb hinzugefügt")
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold))
                    .padding()
                    .background(AppColors.success)
                    .foregroundColor(AppColors.textOnPrimary)
                    .cornerRadius(AppStyles.BorderRadius.medium)
                    .appShadow(AppStyles.Shadows.medium)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if let errorMessage = cartErrorBannerMessage {
                Text(errorMessage)
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold))
                    .padding()
                    .background(AppColors.error)
                    .foregroundColor(AppColors.textOnPrimary)
                    .cornerRadius(AppStyles.BorderRadius.medium)
                    .appShadow(AppStyles.Shadows.medium)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top).padding(.top)
    }
}
