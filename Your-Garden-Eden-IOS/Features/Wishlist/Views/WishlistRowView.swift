// DATEI: WishlistRowView.swift
// PFAD: Features/Wishlist/Views/Components/WishlistRowView.swift
// VERSION: 2.0 (FINAL & VISUELL ANGEGLICHEN)
// ZWECK: Stellt einen Artikel in der Wunschliste dar, visuell angeglichen an die CartRowView,
//        mit einer integrierten Kontrollleiste für die "Zum Warenkorb"-Aktion.

import SwiftUI

struct WishlistRowView: View {
    let product: WooCommerceProduct
    
    let isAddingToCart: Bool
    let onAddToCart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // ===================================================================
            // **STRUKTUR-UPDATE: Ebene 1 - Informations-Anzeige**
            // ===================================================================
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
            .padding([.top, .leading, .trailing])

            // ===================================================================
            // **STRUKTUR-UPDATE: Ebene 2 - Interaktive Kontrollleiste**
            // ===================================================================
            if product.type == "simple" && product.isPurchasable && product.stock_status == .instock {
                HStack {
                    Spacer() // Schiebt den Button nach rechts
                    
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
                .padding([.horizontal, .bottom])
                .padding(.top, AppTheme.Layout.Spacing.xSmall)
            } else {
                // Fügt einen leeren Platzhalter hinzu, damit das Padding konsistent bleibt,
                // auch wenn der Button nicht angezeigt wird.
                Spacer().frame(height: AppTheme.Layout.Spacing.medium + AppTheme.Layout.Spacing.xSmall)
            }
        }
        .background(AppTheme.Colors.backgroundComponent)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.small)
        .opacity(isAddingToCart ? 0.6 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isAddingToCart)
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
