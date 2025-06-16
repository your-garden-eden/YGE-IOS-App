import SwiftUI

struct WishlistRowView: View {
    let product: WooCommerceProduct

    var body: some View {
        HStack(alignment: .center, spacing: AppStyles.Spacing.medium) {
            productImage
            
            VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                Text(product.name.strippingHTML())
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold))
                    .foregroundColor(AppColors.textHeadings)
                    .lineLimit(2)
                
                let priceInfo = PriceFormatter.formatPriceString(from: product.price_html, fallbackPrice: product.price, currencySymbol: "€")
                Text(priceInfo.display)
                    .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                    .foregroundColor(AppColors.price)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textMuted.opacity(0.5))
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
            case .empty:
                ZStack {
                    AppColors.backgroundLightGray
                    ProgressView().tint(AppColors.primary)
                }
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                ZStack {
                    AppColors.backgroundLightGray
                    Image(systemName: "photo.fill")
                        .resizable().scaledToFit()
                        .foregroundColor(AppColors.textMuted.opacity(0.7))
                        .padding(AppStyles.Spacing.medium)
                }
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 80, height: 80)
        .cornerRadius(AppStyles.BorderRadius.medium)
        .clipped()
    }
}
