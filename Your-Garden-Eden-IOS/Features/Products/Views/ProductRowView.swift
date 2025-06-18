// DATEI: ProductRowView.swift
// PFAD: Features/Products/Views/Components/ProductRowView.swift
// ZWECK: Stellt ein Produkt in einer horizontalen Reihen-Ansicht dar,
//        typischerweise für Listen wie im Warenkorb oder auf einer Suchergebnisseite.

import SwiftUI

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
        .padding(AppTheme.Layout.Spacing.medium)
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
                 Image(systemName: "photo.fill")
                    .font(.largeTitle)
                    .foregroundColor(AppTheme.Colors.textMuted.opacity(0.5))
            case .empty:
                ShimmerView()
            @unknown default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var priceView: some View {
        let priceInfo = PriceFormatter.formatPriceString(
            from: product.price_html,
            fallbackPrice: product.price
        )
        Text(priceInfo.display)
            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .bold))
            .foregroundColor(AppTheme.Colors.price)
    }
    
    @ViewBuilder
    private var stockStatusView: some View {
        let isInStock = product.stock_status == .instock
        
        Text(isInStock ? "Auf Lager" : "Nicht verfügbar")
            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .bold))
            .foregroundColor(isInStock ? AppTheme.Colors.success : AppTheme.Colors.error)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((isInStock ? AppTheme.Colors.success : AppTheme.Colors.error).opacity(0.15))
            .cornerRadius(AppTheme.Layout.BorderRadius.small)
    }
}
