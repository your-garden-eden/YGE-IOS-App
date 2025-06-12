//
//  ProductCardView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import SwiftUI

struct ProductCardView: View {
    let product: WooCommerceProduct

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            productImage
            
            VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                Text(product.name.strippingHTML())
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                    .foregroundColor(AppColors.textHeadings)
                    .lineLimit(2)
                    .frame(minHeight: 45, alignment: .top)

                Text((product.priceHtml ?? product.price).strippingHTML())
                    .font(AppFonts.roboto(size: AppFonts.Size.subheadline, weight: .bold))
                    .foregroundColor(AppColors.price)
            }
            .padding(.horizontal, AppStyles.Spacing.medium)
            .padding(.vertical, AppStyles.Spacing.small)
        }
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        // --- FINALE KORREKTUR HIER ---
        .appShadow(AppStyles.Shadows.small)
    }

    private var productImage: some View {
        AsyncImage(url: product.images.first?.src.asURL()) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fit)
            case .failure, .empty:
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.largeTitle)
                    .foregroundColor(AppColors.textMuted.opacity(0.5))
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(AppColors.backgroundLightGray)
            @unknown default:
                ProgressView().tint(AppColors.primary)
                    .frame(maxWidth: .infinity, minHeight: 180)
            }
        }
        .frame(height: 180)
        .clipped()
    }
}
