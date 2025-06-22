// DATEI: WishlistRowView.swift
// PFAD: Features/Wishlist/Views/Components/WishlistRowView.swift
// VERSION: KEHRTWENDE 1.0 (VEREINFACHT)

import SwiftUI

struct WishlistRowView: View {
    let product: WooCommerceProduct
    
    // --- BEGINN MODIFIKATION ---
    // Der onDelete-Parameter wird entfernt, da die Löschung ausschließlich
    // über die Wisch-Geste erfolgt.
    // let onDelete: () -> Void
    // --- ENDE MODIFIKATION ---

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
            
            // --- BEGINN MODIFIKATION ---
            // Der explizite Lösch-Button wird entfernt.
            // Spacer()
            //
            // VStack {
            //     Button(action: onDelete) {
            //         Image(systemName: "trash")
            //             .font(.title3)
            //             .foregroundColor(AppTheme.Colors.error)
            //     }
            //     .frame(width: 44, height: 44)
            //     .buttonStyle(.plain)
            //     .contentShape(Rectangle())
            // }
            // --- ENDE MODIFIKATION ---
        }
    }
    
    @ViewBuilder
    private var productImage: some View {
        ZStack {
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
            
            if product.purchasable != true {
                notAvailableOverlay
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

    @ViewBuilder
    private var notAvailableOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)

            Text("Nicht verfügbar")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.caption, weight: .bold))
                .foregroundColor(.white)
                .padding(AppTheme.Layout.Spacing.xSmall)
                .background(Color.black.opacity(0.4))
                .cornerRadius(AppTheme.Layout.BorderRadius.medium)
        }
    }
}
