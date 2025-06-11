import SwiftUI

struct WishlistRowView: View {
    let product: WooCommerceProduct

    var body: some View {
        HStack(alignment: .center, spacing: AppStyles.Spacing.medium) {
            AsyncImage(url: product.images.first?.src.asURL()) { phase in
                switch phase {
                case .empty:
                    ZStack { AppColors.backgroundLightGray; ProgressView().tint(AppColors.primary) }
                        .frame(width: 70, height: 70).cornerRadius(AppStyles.BorderRadius.medium)
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70).cornerRadius(AppStyles.BorderRadius.medium).clipped()
                case .failure:
                    ZStack { AppColors.backgroundLightGray; Image(systemName: "photo.fill").resizable().scaledToFit().foregroundColor(AppColors.textMuted.opacity(0.7)).padding(10) }
                        .frame(width: 70, height: 70).cornerRadius(AppStyles.BorderRadius.medium)
                @unknown default: EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                Text(product.name)
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold))
                    .foregroundColor(AppColors.textHeadings)
                    .lineLimit(2)
                
                let currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? AppConfig.WooCommerce.defaultCurrencySymbol
                Text("\(currencySymbol)\(product.price)")
                    .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular))
                    .foregroundColor(AppColors.price) // Preis-spezifische Farbe
            }
            Spacer()
        }
        .padding(.vertical, AppStyles.Spacing.small)
    }
}
