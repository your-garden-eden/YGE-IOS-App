// DATEI: WishlistRowView.swift
// PFAD: Features/Wishlist/Views/Components/WishlistRowView.swift
// ZWECK: Stellt einen einzelnen Artikel (eine Zeile) in der Wunschliste dar.

import SwiftUI

struct WishlistRowView: View {
    let product: WooCommerceProduct
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Layout.Spacing.medium) {
            productImage
                .frame(width: 90, height: 90)
                .cornerRadius(AppTheme.Layout.BorderRadius.medium)

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
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                 Image(systemName: "photo.fill")
                    .font(.largeTitle)
                    .foregroundColor(AppTheme.Colors.textMuted.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.Colors.backgroundLightGray)
            case .empty:
                ShimmerView()
            @unknown default:
                EmptyView()
            }
        }
        .clipped()
    }
    
    @ViewBuilder
    private var priceView: some View {
        let priceInfo = PriceFormatter.formatPriceString(
            from: product.price_html,
            fallbackPrice: product.price
        )
        HStack(spacing: AppTheme.Layout.Spacing.small) {
            Text(priceInfo.display)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .bold))
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
    private var stockStatusView: some View {
        let isInStock = product.stock_status == .instock
        
        Text(isInStock ? "Auf Lager" : "Nicht verfügbar")
            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .bold))
            .foregroundColor(isInStock ? AppTheme.Colors.success : AppTheme.Colors.error)
    }
}
