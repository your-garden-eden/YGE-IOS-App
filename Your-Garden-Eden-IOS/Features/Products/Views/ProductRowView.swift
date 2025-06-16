import SwiftUI

struct ProductRowView: View {
    let product: WooCommerceProduct

    var body: some View {
        HStack(alignment: .top, spacing: AppStyles.Spacing.medium) {
            productImage
                .frame(width: 90, height: 90)
                .background(AppColors.backgroundLightGray)
                .cornerRadius(AppStyles.BorderRadius.medium)
                .clipped()

            VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                Text(product.name.strippingHTML())
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                    .foregroundColor(AppColors.textHeadings)
                    .lineLimit(2)
                
                Spacer()
                
                priceView
                
                stockStatusView
            }
            .frame(height: 90)
        }
        .padding(AppStyles.Spacing.medium)
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        .appShadow(AppStyles.Shadows.small)
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
                    .foregroundColor(AppColors.textMuted.opacity(0.5))
            case .empty:
                ShimmerView()
            @unknown default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var priceView: some View {
        let priceInfo = PriceFormatter.formatPriceString(
            from: product.price_html,
            fallbackPrice: product.price,
            currencySymbol: "€"
        )
        Text(priceInfo.display)
            .font(AppFonts.roboto(size: AppFonts.Size.subheadline, weight: .bold))
            .foregroundColor(AppColors.price)
    }
    
    @ViewBuilder
    private var stockStatusView: some View {
        let isInStock = product.stock_status == .instock
        
        Text(isInStock ? "Auf Lager" : "Nicht verfügbar")
            .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .bold))
            .foregroundColor(isInStock ? AppColors.success : AppColors.error)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background((isInStock ? AppColors.success : AppColors.error).opacity(0.15))
            .cornerRadius(AppStyles.BorderRadius.small)
    }
}
