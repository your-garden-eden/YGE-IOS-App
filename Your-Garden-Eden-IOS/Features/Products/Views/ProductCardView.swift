// Path: Your-Garden-Eden-IOS/Features/Products/Views/ProductCardView.swift
// VERSION 2.0 (FINAL - Intelligent Stock & Variation Display)

import SwiftUI

struct ProductCardView: View {
    let product: WooCommerceProduct

    var body: some View {
        NavigationLink(value: product) {
            VStack(alignment: .leading, spacing: 0) {
                
                // --- BILD & OVERLAYS ---
                imageWithOverlays
                    .aspectRatio(1.0, contentMode: .fit) // Sorgt für quadratische Bilder
                
                // --- TEXT-INHALT ---
                VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                    Text(product.name.strippingHTML())
                        .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
                        .foregroundColor(AppColors.textBase)
                        .lineLimit(2)
                        .frame(height: 40, alignment: .top) // Feste Höhe für einheitliches Layout

                    priceView
                }
                .padding(AppStyles.Spacing.small)
            }
            .background(AppColors.backgroundComponent)
            .cornerRadius(AppStyles.BorderRadius.medium)
            .appShadow(AppStyles.Shadows.small)
            .grayscale(product.stock_status == .outofstock ? 1.0 : 0.0) // Graustufen für ausverkaufte Produkte
            .opacity(product.stock_status == .outofstock ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Subviews

    private var imageWithOverlays: some View {
        ZStack(alignment: .topTrailing) {
            // Bild
            AsyncImage(url: product.safeImages.first?.src.asURL()) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle().fill(AppColors.backgroundLightGray)
                        .overlay(Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.borderLight))
                }
            }
            
            // --- HIER IST DIE NEUE LOGIK FÜR DIE STATUS-ANZEIGE ---
            VStack(alignment: .trailing, spacing: AppStyles.Spacing.xSmall) {
                if product.isOnSale {
                    saleBadge
                }
                stockInfoOverlay // Unser neuer intelligenter Overlay
            }
            .padding(AppStyles.Spacing.small)
        }
        .clipped()
    }
    
    @ViewBuilder
    private var stockInfoOverlay: some View {
        // Logik zur Bestimmung, welcher Badge angezeigt wird
        if product.stock_status == .outofstock {
            StockInfoBadge(
                text: "Ausverkauft",
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textOnPrimary,
                fontWeight: .bold
            )
        } else if product.type == "variable" {
            StockInfoBadge(
                text: "Variationen verfügbar",
                backgroundColor: AppColors.textMuted.opacity(0.8),
                foregroundColor: .white,
                fontWeight: .regular
            )
        }
    }

    private var saleBadge: some View {
        Text("Angebot")
            .font(AppFonts.montserrat(size: AppFonts.Size.caption, weight: .bold))
            .padding(.horizontal, AppStyles.Spacing.small)
            .padding(.vertical, AppStyles.Spacing.xSmall / 2)
            .background(AppColors.primary)
            .foregroundColor(AppColors.textOnPrimary)
            .cornerRadius(AppStyles.BorderRadius.small)
    }
    
    @ViewBuilder
    private var priceView: some View {
        if let priceRange = product.priceRangeDisplay {
             Text(priceRange)
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular))
                .foregroundColor(AppColors.textMuted)
        } else {
            let formattedPrice = PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price)
            HStack(spacing: AppStyles.Spacing.small) {
                Text(formattedPrice.display)
                    .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                    .foregroundColor(AppColors.price)
                
                if let strikethrough = formattedPrice.strikethrough {
                    Text(strikethrough)
                        .font(AppFonts.roboto(size: AppFonts.Size.subheadline))
                        .strikethrough()
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
    }
}


// MARK: - Helper View für die Badges
fileprivate struct StockInfoBadge: View {
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color
    let fontWeight: Font.Weight

    var body: some View {
        Text(text)
            .font(AppFonts.montserrat(size: AppFonts.Size.caption, weight: fontWeight))
            .padding(.horizontal, AppStyles.Spacing.small)
            .padding(.vertical, AppStyles.Spacing.xSmall / 2)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(AppStyles.BorderRadius.small)
            .transition(.opacity.animation(.easeIn))
    }
}
