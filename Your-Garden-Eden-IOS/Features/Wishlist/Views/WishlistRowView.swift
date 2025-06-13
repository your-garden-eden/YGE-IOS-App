// Dateiname: WishlistRowView.swift

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
                
                // Preis-Anzeige mit korrekter Währung
                Text((product.priceHtml ?? product.price).strippingHTML())
                    .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                    .foregroundColor(AppColors.price)
            }
            
            Spacer()
        }
        .padding(AppStyles.Spacing.medium) // Innenabstand für die Karte
        .background(AppColors.backgroundComponent) // Kartenhintergrund
        .cornerRadius(AppStyles.BorderRadius.large) // Abgerundete Ecken
        .appShadow(AppStyles.Shadows.small) // Dezenter Schatten
    }
    
    @ViewBuilder
    private var productImage: some View {
        AsyncImage(url: product.images.first?.src.asURL()) { phase in
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
        .frame(width: 80, height: 80) // Feste Größe für einheitliches Layout
        .cornerRadius(AppStyles.BorderRadius.medium)
        .clipped()
    }
}
