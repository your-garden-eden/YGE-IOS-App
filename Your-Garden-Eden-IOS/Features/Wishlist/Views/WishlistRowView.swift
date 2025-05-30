// Features/Wishlist/Views/WishlistRowView.swift
import SwiftUI

struct WishlistRowView: View {
    let product: WooCommerceProduct

    var body: some View {
        HStack(alignment: .center, spacing: AppStyles.Spacing.medium) {
            // Produktbild
            // KORREKTUR HIER: Verwende product.images.first?.src anstatt .thumbnail
            AsyncImage(url: product.images.first?.src.asURL()) { phase in
                switch phase {
                case .empty:
                    ZStack { AppColors.backgroundLightGray; ProgressView().tint(AppColors.primary) }
                        .frame(width: 70, height: 70).cornerRadius(AppStyles.BorderRadius.small)
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill) // .fill, um den Frame auszufüllen
                        .frame(width: 70, height: 70).cornerRadius(AppStyles.BorderRadius.small).clipped() // .clipped bei .fill
                case .failure:
                    ZStack { AppColors.backgroundLightGray; Image(systemName: "photo.fill").resizable().scaledToFit().foregroundColor(AppColors.textMuted.opacity(0.7)).padding(10) }
                        .frame(width: 70, height: 70).cornerRadius(AppStyles.BorderRadius.small)
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
                    .foregroundColor(AppColors.textBase)
            }
            Spacer()
        }
        .padding(.vertical, AppStyles.Spacing.small)
    }
}

// Preview Provider für WishlistRowView
struct WishlistRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Da WooCommerceProduct komplex ist, ist das Erstellen einer Instanz hier aufwändig.
        // Für eine funktionierende Preview ohne Mocking müsste man eine Methode haben,
        // um ein echtes (oder zumindest valides leeres) Produkt zu erzeugen.
        Text("Preview für WishlistRowView (benötigt valide Produktdaten für die Bildanzeige)")
        // Beispiel, falls du einen einfachen Initializer für WooCommerceProduct hättest:
        // WishlistRowView(product: WooCommerceProduct(id: 1, name: "Vorschau Produkt", images: [WooCommerceImage(id:1, src:"https://via.placeholder.com/70", ...)], ...))
    }
}
