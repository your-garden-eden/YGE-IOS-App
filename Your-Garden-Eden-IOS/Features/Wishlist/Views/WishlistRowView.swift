// DATEI: WishlistRowView.swift
// PFAD: Features/Wishlist/Views/Components/WishlistRowView.swift
// VERSION: FINAL - Alle Operationen integriert.

import SwiftUI

struct WishlistRowView: View {
    let product: WooCommerceProduct
    
    let onDelete: () -> Void

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
                
                priceView
                
                Spacer()
            }
            .frame(height: 90)
            
            Spacer()
            
            VStack {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.error)
                }
                .frame(width: 44, height: 44)
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
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
        let priceInfo = PriceFormatter.formatDisplayPrice(for: product)
        Text(priceInfo.display)
            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .bold))
            .foregroundColor(AppTheme.Colors.price)
    }
}
