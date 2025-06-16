// Path: Your-Garden-Eden-IOS/Features/Products/Views/ProductCardView.swift
// VERSION 3.0 (FINAL - Handles Calculated Price Ranges)

import SwiftUI

struct ProductCardView: View {
    let product: WooCommerceProduct

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            imageSection
            infoSection
        }
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        .appShadow(AppStyles.Shadows.medium)
    }

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: product.safeImages.first?.src.asURL()) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    ZStack {
                        AppColors.backgroundLightGray
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle).foregroundColor(AppColors.textMuted.opacity(0.5))
                    }
                default:
                    ShimmerView()
                }
            }
            .frame(height: 150)
            .clipped()

            if !product.isPurchasable || product.stock_status != .instock {
                Text("Derzeit nicht bestellbar")
                    .font(AppFonts.montserrat(size: 10, weight: .bold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(AppColors.textMuted.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(AppStyles.BorderRadius.small)
                    .padding(AppStyles.Spacing.small)
            } else if product.isOnSale {
                Text("Sale")
                    .font(AppFonts.montserrat(size: 12, weight: .bold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(AppColors.error)
                    .foregroundColor(.white)
                    .cornerRadius(AppStyles.BorderRadius.small)
                    .padding(AppStyles.Spacing.small)
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
            Text(product.name.strippingHTML())
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                .lineLimit(2)
                .frame(minHeight: 40, alignment: .top)

            if product.isPurchasable && product.stock_status == .instock {
                // PRIORITÄT 1: Prüfen, ob eine berechnete Preisspanne vorhanden ist.
                if let priceRange = product.priceRangeDisplay {
                    Text(priceRange)
                        .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold))
                        .foregroundColor(AppColors.price)
                } else {
                    // PRIORITÄT 2: Wenn nicht, den normalen PriceFormatter verwenden.
                    let priceInfo = PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price)
                    HStack(alignment: .bottom) {
                        Text(priceInfo.display)
                            .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold))
                            .foregroundColor(AppColors.price)
                        
                        if let strikethrough = priceInfo.strikethrough {
                            Text(strikethrough)
                                .font(AppFonts.roboto(size: AppFonts.Size.caption))
                                .strikethrough()
                                .foregroundColor(AppColors.textMuted)
                        }
                        Spacer()
                    }
                }
            } else {
                Spacer().frame(height: AppFonts.Size.headline)
            }
        }
        .padding(AppStyles.Spacing.medium)
    }
}
