// Path: Your-Garden-Eden-IOS/Features/Products/Views/ProductCardView.swift

import SwiftUI

struct ProductCardView: View {
    let product: WooCommerceProduct

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            imageSection
                .frame(height: 120)
                .clipped()

            infoSection
                .padding(.horizontal, AppStyles.Spacing.small)
                .padding(.bottom, AppStyles.Spacing.small)
        }
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        .appShadow(AppStyles.Shadows.small)
    }

    @ViewBuilder
    private var imageSection: some View {
        ZStack {
            AsyncImage(url: product.images.first?.src.asURL()) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(AppColors.backgroundLightGray)
                        .overlay(ProgressView().tint(AppColors.primary))
                }
            }
            if product.onSale {
                VStack {
                    HStack {
                        Spacer()
                        Text("Sale")
                            .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.error)
                            .cornerRadius(AppStyles.BorderRadius.small)
                            .padding(AppStyles.Spacing.small)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
            Text(product.name.strippingHTML())
                .font(AppFonts.montserrat(size: AppFonts.Size.caption, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
                .lineLimit(2)
                .frame(height: 35, alignment: .top)

            let priceInfo = PriceFormatter.formatPriceString(from: product.priceHtml, fallbackPrice: product.price, currencySymbol: "€")
            HStack(alignment: .bottom, spacing: 4) {
                Text(priceInfo.display)
                    .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                    .foregroundColor(AppColors.price)
                if let strikethrough = priceInfo.strikethrough {
                    Text(strikethrough)
                        .font(AppFonts.roboto(size: AppFonts.Size.caption))
                        .strikethrough()
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
    }
}
