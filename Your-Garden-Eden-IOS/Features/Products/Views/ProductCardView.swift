// DATEI: ProductCardView.swift
// PFAD: Features/Products/Views/Components/ProductCardView.swift
// ZWECK: Eine wiederverwendbare Karte zur Darstellung eines einzelnen Produkts in einer Gitter- oder Listenansicht.

import SwiftUI

struct ProductCardView: View {
    let product: WooCommerceProduct

    var body: some View {
        NavigationLink(value: product) {
            VStack(alignment: .leading, spacing: 0) {
                imageWithOverlays
                    .aspectRatio(1.0, contentMode: .fit)
                
                VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xSmall) {
                    Text(product.name.strippingHTML())
                        .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body, weight: .regular))
                        .foregroundColor(AppTheme.Colors.textBase)
                        .lineLimit(2)
                        .frame(height: 40, alignment: .top)

                    priceView
                }
                .padding(AppTheme.Layout.Spacing.small)
            }
            .background(AppTheme.Colors.backgroundComponent)
            .cornerRadius(AppTheme.Layout.BorderRadius.medium)
            .appShadow(AppTheme.Shadows.small)
            .grayscale(product.stock_status == .outofstock ? 1.0 : 0.0)
            .opacity(product.stock_status == .outofstock ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Subviews
    private var imageWithOverlays: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: product.safeImages.first?.src.asURL()) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Rectangle().fill(AppTheme.Colors.backgroundLightGray)
                        .overlay(Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppTheme.Colors.borderLight))
                }
            }
            
            VStack(alignment: .trailing, spacing: AppTheme.Layout.Spacing.xSmall) {
                if product.isOnSale {
                    saleBadge
                }
                stockInfoOverlay
            }
            .padding(AppTheme.Layout.Spacing.small)
        }
        .clipped()
    }
    
    @ViewBuilder
    private var stockInfoOverlay: some View {
        if product.stock_status == .outofstock {
            StockInfoBadge(text: "Ausverkauft", backgroundColor: AppTheme.Colors.error, foregroundColor: AppTheme.Colors.textOnPrimary, fontWeight: .bold)
        } else if product.type == "variable" {
            StockInfoBadge(text: "Variationen verfügbar", backgroundColor: AppTheme.Colors.textMuted.opacity(0.8), foregroundColor: .white, fontWeight: .regular)
        }
    }

    private var saleBadge: some View {
        Text("Angebot")
            .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.caption, weight: .bold))
            .padding(.horizontal, AppTheme.Layout.Spacing.small)
            .padding(.vertical, AppTheme.Layout.Spacing.xSmall / 2)
            .background(AppTheme.Colors.primary)
            .foregroundColor(AppTheme.Colors.textOnPrimary)
            .cornerRadius(AppTheme.Layout.BorderRadius.small)
    }
    
    @ViewBuilder
    private var priceView: some View {
        if let priceRange = product.priceRangeDisplay {
             Text(priceRange)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .regular))
                .foregroundColor(AppTheme.Colors.textMuted)
        } else {
            let formattedPrice = PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price)
            HStack(spacing: AppTheme.Layout.Spacing.small) {
                Text(formattedPrice.display)
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .bold))
                    .foregroundColor(AppTheme.Colors.price)
                
                if let strikethrough = formattedPrice.strikethrough {
                    Text(strikethrough)
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline))
                        .strikethrough()
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
            }
        }
    }
}

// Eine kleine, private Hilfs-View, die nur innerhalb von ProductCardView verwendet wird.
fileprivate struct StockInfoBadge: View {
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color
    let fontWeight: Font.Weight

    var body: some View {
        Text(text)
            .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.caption, weight: fontWeight))
            .padding(.horizontal, AppTheme.Layout.Spacing.small)
            .padding(.vertical, AppTheme.Layout.Spacing.xSmall / 2)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(AppTheme.Layout.BorderRadius.small)
            .transition(.opacity.animation(.easeIn))
    }
}
