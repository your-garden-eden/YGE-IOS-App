//
//  ProductRowView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import SwiftUI

struct ProductRowView: View {
    let product: WooCommerceProduct

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            productImage
                .frame(width: 90, height: 90)
                .background(AppColors.backgroundLightGray)
                .cornerRadius(AppStyles.BorderRadius.medium)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(product.name.strippingHTML())
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                    .foregroundColor(AppColors.textHeadings)
                    .lineLimit(2)
                
                Spacer()
                
                Text((product.priceHtml ?? product.price).strippingHTML())
                    .font(AppFonts.roboto(size: AppFonts.Size.subheadline, weight: .bold))
                    .foregroundColor(AppColors.price)
                
                stockStatusView
            }
            .frame(height: 90)
        }
        .padding(AppStyles.Spacing.medium)
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
    }
    
    @ViewBuilder
    private var productImage: some View {
        AsyncImage(url: product.images.first?.src.asURL()) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure, .empty:
                Image(systemName: "photo.fill")
                    .font(.largeTitle)
                    .foregroundColor(AppColors.textMuted.opacity(0.5))
            @unknown default:
                ProgressView().tint(AppColors.primary)
            }
        }
    }
    
    @ViewBuilder
    private var stockStatusView: some View {
        let isInStock = product.stockStatus == .instock
        
        Text(isInStock ? "Auf Lager" : "Nicht verfügbar")
            .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .bold))
            .foregroundColor(isInStock ? AppColors.success : AppColors.error)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((isInStock ? AppColors.success : AppColors.error).opacity(0.15))
            .cornerRadius(AppStyles.BorderRadius.small)
    }
}
