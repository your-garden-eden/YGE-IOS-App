//
//  ProductDetailView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @EnvironmentObject var wishlistState: WishlistState
    
    @State private var showAddedToCartConfirmation = false

    init(product: WooCommerceProduct) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppStyles.Spacing.xLarge) {
                    productGallery
                    productHeader
                    
                    // KORREKTUR: Verwendet den korrekten String-Vergleich.
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
        .navigationTitle(viewModel.product.name.strippingHTML())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadVariationsIfNeeded() }
        .overlay(addedToCartBanner)
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
                Text(viewModel.product.name.strippingHTML())
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
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            Text("Beschreibung").font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            
            ExpandableText(text: viewModel.product.description.strippingHTML(), lineLimit: 4)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var bottomActionSection: some View {
        VStack(spacing: 12) {
            // KORREKTUR: Verwendet den korrekten String-Vergleich.
            if viewModel.effectiveProductType == "simple" {
                if !viewModel.product.soldIndividually {
                    QuantitySelectorView(quantity: $viewModel.quantity)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        let success = await viewModel.addSimpleProductToCart()
                        if success {
                            withAnimation { showAddedToCartConfirmation = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showAddedToCartConfirmation = false }
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
            
            // KORREKTUR: Verwendet den korrekten String-Vergleich.
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
    
    @ViewBuilder private var addedToCartBanner: some View {
        if showAddedToCartConfirmation {
            Text("Zum Warenkorb hinzugefügt")
                .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold))
                .padding()
                .background(AppColors.success)
                .foregroundColor(AppColors.textOnPrimary)
                .cornerRadius(AppStyles.BorderRadius.medium)
                .appShadow(AppStyles.Shadows.medium)
                .transition(.move(edge: .top).combined(with: .opacity))
                .frame(maxHeight: .infinity, alignment: .top).padding(.top)
        }
    }
}
