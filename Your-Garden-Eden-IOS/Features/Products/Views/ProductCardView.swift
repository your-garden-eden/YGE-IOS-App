// DATEI: ProductCardView.swift
// PFAD: Features/Products/Views/Components/ProductCardView.swift
// VERSION: FINAL - Alle Operationen integriert.

import SwiftUI

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
}
