// Components/ProductCardView.swift
import SwiftUI

struct ProductCardView: View {
    @EnvironmentObject var wishlistState: WishlistState
    @EnvironmentObject var authManager: FirebaseAuthManager

    var product: WooCommerceProduct
    @State private var showingAuthSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) { // Geringerer Abstand für kompaktere Infos
            // MARK: - Bild
            AsyncImage(url: product.images.first?.src.asURL()) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        AppColors.backgroundLightGray // Hellerer Placeholder
                        ProgressView().tint(AppColors.primary)
                    }
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fit) // .fit ist oft besser für Produktbilder
                case .failure:
                    ZStack {
                        AppColors.backgroundLightGray
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(AppColors.textMuted.opacity(0.6))
                            .padding(AppStyles.Spacing.large) // Etwas Padding für das Icon
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 150) // Höhe beibehalten oder anpassen
            .clipped()
            .cornerRadius(AppStyles.BorderRadius.medium) // Ecken nur für das Bild, wenn die Karte selbst rechteckig ist
            .padding(.bottom, AppStyles.Spacing.small)

            // MARK: - Produktname
            Text(product.name)
                .font(AppFonts.montserrat(size: AppFonts.Size.smallBody, weight: .semibold)) // Etwas kleiner für Karten
                .foregroundColor(AppColors.textHeadings)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true) // Erlaubt Umbruch auf max 2 Zeilen

            Spacer() // Drückt Preis und Herz nach unten

            // MARK: - Preis und Herz-Button
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) { // Für Preis und ggf. Streichpreis
                    let currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? AppConfig.WooCommerce.defaultCurrencySymbol // Fallback auf Config
                    Text("\(currencySymbol)\(product.price)")
                        .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold))
                        .foregroundColor(AppColors.price)
                    
                    // Optional: Regulärer Preis (Streichpreis)
                    if product.onSale && !product.regularPrice.isEmpty && product.regularPrice != product.price {
                        Text("\(currencySymbol)\(product.regularPrice)")
                            .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .regular))
                            .foregroundColor(AppColors.textMuted)
                            .strikethrough(true, color: AppColors.textMuted)
                    }
                }
                
                Spacer() // Schiebt Herz-Button nach rechts

                Button {
                    if authManager.user != nil {
                        wishlistState.toggleWishlistStatus(for: product.id)
                    } else {
                        showingAuthSheet = true
                    }
                } label: {
                    Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                        .font(.title3) // Größe des Herzens anpassen
                        .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? AppColors.wishlistIcon : AppColors.textMuted)
                        .padding(AppStyles.Spacing.xSmall / 2) // Kleinerer Klickbereich, wenn das Icon selbst die Referenz ist
                        // Optional: Hintergrund für besseren Kontrast, falls nötig
                        // .background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding(.top, AppStyles.Spacing.xSmall) // Kleiner Abstand über Preis/Herz
        }
        .padding(AppStyles.Spacing.small) // Innenabstand der gesamten Karte
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large) // Abgerundete Ecken für die Karte
        .appShadow(AppStyles.Shadows.small) // Schatten für die Karte
        .sheet(isPresented: $showingAuthSheet) {
            AuthContainerView(onDismiss: { showingAuthSheet = false })
                .environmentObject(authManager)
        }
    }
}

// Hilfsextension für URL-Konvertierung (falls noch nicht vorhanden)
extension String {
    func asURL() -> URL? {
        URL(string: self)
    }
}

// AppConfig-Erweiterung (Beispiel, falls du es so machen willst)
// Füge dies zu deiner AppConfig.swift hinzu oder an einen anderen geeigneten Ort
// struct AppConfig {
//     struct WooCommerce {
//         // ... deine anderen WooCommerce-Konfigurationen ...
//         static let defaultCurrencySymbol = "€" // Standard-Währungssymbol
//     }
//     // ...
// }
