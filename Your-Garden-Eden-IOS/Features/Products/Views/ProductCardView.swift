
// DATEI: ProductComponentViews.swift
// PFAD: Features/Products/Views/Components/ProductComponentViews.swift
// VERSION: 1.1 (FINAL KORRIGIERT)
// STATUS: Vollständig synchronisiert.

import SwiftUI

// MARK: - ProductCardView
struct ProductCardView: View {
    let product: WooCommerceProduct
    @EnvironmentObject private var wishlistState: WishlistState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                productImage
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
                
                if product.purchasable != true {
                    notAvailableOverlay
                }
                
                wishlistButton
                    .padding(AppTheme.Layout.Spacing.small)
            }
            
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xSmall) {
                Text(product.name.strippingHTML())
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.caption, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textHeadings)
                    .lineLimit(2)
                    .frame(height: 35, alignment: .top)

                Spacer()
                
                priceView
            }
            .padding(AppTheme.Layout.Spacing.small)
            .frame(height: 70)
        }
        .background(AppTheme.Colors.backgroundComponent)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.small)
    }
    
    @ViewBuilder
    private var productImage: some View {
        AsyncImage(url: product.safeImages.first?.src.asURL()) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                 Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppTheme.Colors.textMuted.opacity(0.5))
            default:
                ShimmerView()
            }
        }
    }
    
    @ViewBuilder
    private var wishlistButton: some View {
        Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
            .font(.title3)
            .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? AppTheme.Colors.error : AppTheme.Colors.secondary)
            .padding(AppTheme.Layout.Spacing.xSmall)
            .background(.regularMaterial, in: Circle())
            .contentShape(Rectangle())
            .onTapGesture {
                wishlistState.toggleWishlistStatus(for: product)
            }
            .animation(.spring(), value: wishlistState.isProductInWishlist(productId: product.id))
    }
    
    @ViewBuilder
    private var priceView: some View {
        let priceInfo = PriceFormatter.formatDisplayPrice(for: product)
        
        HStack(spacing: AppTheme.Layout.Spacing.small) {
            Text(priceInfo.display)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .bold))
                .foregroundColor(AppTheme.Colors.price)
            
            if let strikethrough = priceInfo.strikethrough {
                Text(strikethrough)
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption))
                    .strikethrough()
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
        }
    }

    @ViewBuilder
    private var notAvailableOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
            Text("Nicht verfügbar")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.caption, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.Layout.Spacing.medium)
                .padding(.vertical, AppTheme.Layout.Spacing.small)
                .background(Color.black.opacity(0.4))
                .cornerRadius(AppTheme.Layout.BorderRadius.large)
        }
    }
}

// MARK: - ProductRowView
struct ProductRowView: View {
    let product: WooCommerceProduct

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Layout.Spacing.medium) {
            productImage
                .frame(width: 90, height: 90)
                .background(AppTheme.Colors.backgroundLightGray)
                .cornerRadius(AppTheme.Layout.BorderRadius.medium)
                .clipped()

            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xSmall) {
                Text(product.name.strippingHTML())
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textHeadings)
                    .lineLimit(2)
                
                Spacer()
                
                priceView
                
                stockStatusView
            }
            .frame(height: 90)
        }
    }
    
    @ViewBuilder
    private var productImage: some View {
        AsyncImage(url: product.safeImages.first?.src.asURL()) { phase in
            switch phase {
            case .success(let image): image.resizable().aspectRatio(contentMode: .fill)
            case .failure: Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppTheme.Colors.textMuted.opacity(0.5))
            case .empty: ShimmerView()
            @unknown default: EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var priceView: some View {
        // KORREKTUR: Veralteten 'formatPriceString'-Aufruf durch 'formatDisplayPrice' ersetzt.
        let priceInfo = PriceFormatter.formatDisplayPrice(for: product)
        Text(priceInfo.display)
            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .bold))
            .foregroundColor(AppTheme.Colors.price)
    }
    
    @ViewBuilder
    private var stockStatusView: some View {
        // KORREKTUR: 'stock_status' zu 'stockStatus' geändert.
        if let stock = product.stockStatus {
            let isInStock = stock == .instock
            Text(isInStock ? "Auf Lager" : "Nicht verfügbar")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .bold))
                .foregroundColor(isInStock ? AppTheme.Colors.success : AppTheme.Colors.error)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background((isInStock ? AppTheme.Colors.success : AppTheme.Colors.error).opacity(0.15))
                .cornerRadius(AppTheme.Layout.BorderRadius.small)
        }
    }
}

// MARK: - RelatedProductsView
struct RelatedProductsView: View {
    let title: String
    let products: [WooCommerceProduct]

    var body: some View {
        if !products.isEmpty {
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.medium) {
                if !title.isEmpty {
                    Text(title)
                        .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h6, weight: .semibold))
                        .padding(.horizontal)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Layout.Spacing.medium) {
                        ForEach(products) { product in
                            NavigationLink(value: product) {
                                ProductCardView(product: product).frame(width: 160)
                            }.buttonStyle(.plain)
                        }
                    }.padding(.horizontal)
                }
            }.padding(.vertical)
        }
    }
}

// MARK: - AttributeSelectorView
struct AttributeSelectorView: View {
    let attribute: ProductOptionsViewModel.DisplayableAttribute
    let availableOptionSlugs: Set<String>
    let selectedOptionSlug: String?
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) {
            Text(attribute.name)
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(attribute.options) { option in
                        let isSelected = (selectedOptionSlug == option.slug)
                        let isAvailable = availableOptionSlugs.contains(option.slug) || isSelected
                        
                        Button(action: { onSelect(option.slug) }) {
                            Text(option.name)
                                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .bold))
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.backgroundLightGray)
                                .foregroundColor(isSelected ? .white : (isAvailable ? AppTheme.Colors.primary : AppTheme.Colors.textMuted))
                                .cornerRadius(AppTheme.Layout.BorderRadius.large)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Layout.BorderRadius.large)
                                        .stroke(isAvailable ? AppTheme.Colors.primary : AppTheme.Colors.textMuted, lineWidth: isSelected ? 0 : 1.5)
                                )
                                .overlay(
                                    Rectangle().frame(height: 1.5).foregroundColor(AppTheme.Colors.error.opacity(0.8))
                                        .rotationEffect(Angle(degrees: -10)).padding(.horizontal, -4).opacity(isAvailable ? 0 : 1)
                                )
                        }
                        .disabled(!isAvailable)
                        .animation(.easeInOut(duration: 0.2), value: isAvailable)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                    }
                }
                .padding(.bottom, 4)
            }
        }
    }
}

