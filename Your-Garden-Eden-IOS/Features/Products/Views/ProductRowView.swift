// YGE-IOS-App/Features/Products/Views/ProductRowView.swift
import SwiftUI

struct ProductRowView: View {
    let product: WooCommerceProduct

    var body: some View {
        HStack(alignment: .top, spacing: AppStyles.Spacing.medium) {
            // MARK: - Produktbild
            if let firstImage = product.images.first, let imageUrl = URL(string: firstImage.src) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                            .background(AppColors.backgroundLightGray)
                            .clipShape(RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium))
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: 80, height: 80)
                             .clipShape(RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium))
                             .overlay(
                                 RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                                     .stroke(AppColors.borderLight, lineWidth: 1)
                             )
                    case .failure:
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(AppColors.textMuted.opacity(0.7))
                            .frame(width: 50, height: 50)
                            .frame(width: 80, height: 80) // Äußerer Rahmen
                            .background(AppColors.backgroundLightGray)
                            .clipShape(RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                    .fill(AppColors.backgroundLightGray)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title)
                            .foregroundColor(AppColors.textMuted.opacity(0.7))
                    )
            }

            // MARK: - Produktdetails
            VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                Text(product.name)
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold))
                    .foregroundColor(AppColors.textHeadings)
                    .lineLimit(2)

                if !product.shortDescription.isEmpty {
                    Text(product.shortDescription.strippingHTML())
                        .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .regular))
                        .foregroundColor(AppColors.textMuted)
                        .lineLimit(2)
                        .padding(.top, AppStyles.Spacing.xxSmall)
                }
                
                Spacer() // Drückt Preis und Status nach unten

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: AppStyles.Spacing.xxSmall) {
                        // Preis
                        Text(product.price + (product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? " €"))
                            .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold))
                            .foregroundColor(AppColors.price)

                        // Regulärer Preis, wenn Sale
                        if product.onSale &&
                           product.regularPrice != product.price &&
                           !product.regularPrice.isEmpty { // Direkte Prüfung, da product.regularPrice nicht optional ist
                            Text(product.regularPrice + (product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? " €"))
                                .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .regular))
                                .foregroundColor(AppColors.textMuted)
                                .strikethrough()
                        }
                    }
                    
                    Spacer() // Schiebt Lagerstatus nach rechts
                    
                    // Lagerstatus (vereinfacht)
                    // Das 'if let' wurde entfernt, da product.stockStatus nicht optional ist.
                    Text(product.stockStatus == .instock ? "Auf Lager" : (product.backordersAllowed ? "Lieferbar" : "Ausverkauft"))
                        .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .medium))
                        .foregroundColor(product.stockStatus == .instock ? AppColors.inStock : (product.backordersAllowed ? AppColors.warning : AppColors.error))
                        .padding(.horizontal, AppStyles.Spacing.small)
                        .padding(.vertical, AppStyles.Spacing.xxSmall)
                        .background((product.stockStatus == .instock ? AppColors.inStock : (product.backordersAllowed ? AppColors.warning : AppColors.error)).opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .frame(minHeight: 70)
        }
    }
}

