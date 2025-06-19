// DATEI: WishlistRowView.swift
// PFAD: Features/Wishlist/Views/Components/WishlistRowView.swift
// VERSION: 3.0 (OPERATION: SYNCHRONISATION)
// ZWECK: Stellt einen Artikel in der Wunschliste dar, visuell angeglichen an die CartRowView.

import SwiftUI

struct WishlistRowView: View {
    let product: WooCommerceProduct
    
    let isAddingToCart: Bool
    let onAddToCart: () -> Void
    // NEU: Closure für die Lösch-Aktion
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
                
                // HINWEIS: Der Mengen-Selektor wird bewusst weggelassen.
            }
            .frame(height: 90)
            
            Spacer()
            
            // NEU: Expliziter Lösch-Button, angelehnt an das Warenkorb-Design
            VStack {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.error)
                }
                .frame(width: 44, height: 44)
                
                Spacer()
                
                // Behält den "Zum Warenkorb"-Button bei
                if product.type == "simple" && product.isPurchasable && product.stock_status == .instock {
                    Button(action: onAddToCart) {
                        if isAddingToCart {
                            ProgressView()
                                .tint(AppTheme.Colors.primary)
                        } else {
                            Image(systemName: "cart.badge.plus")
                                .font(.title2)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .disabled(isAddingToCart)
                }
            }
        }
        // HINWEIS: Das Styling für die Karte wird jetzt von der übergeordneten WishlistView gehandhabt.
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
        let priceInfo = PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price)
        Text(priceInfo.display)
            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .bold))
            .foregroundColor(AppTheme.Colors.price)
    }
}
