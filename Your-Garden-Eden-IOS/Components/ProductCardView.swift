// Components/ProductCardView.swift
import SwiftUI

struct ProductCardView: View {
    @EnvironmentObject var wishlistState: WishlistState
    // authManager ist für die reine Herz-Funktion nicht mehr nötig, da WishlistState das intern prüft.
    // Kann aber für andere Zwecke auf der Karte verbleiben.
    // @EnvironmentObject var authManager: FirebaseAuthManager

    var product: WooCommerceProduct
    // showingAuthSheet wird für das Herz nicht mehr benötigt
    // @State private var showingAuthSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
            // MARK: - Bild
            AsyncImage(url: product.images.first?.src.asURL()) { phase in
                switch phase {
                case .empty:
                    ZStack { AppColors.backgroundLightGray; ProgressView().tint(AppColors.primary) }
                        .frame(height: 150).cornerRadius(AppStyles.BorderRadius.medium)
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit) // .fit für Produktbilder
                        .frame(height: 150).cornerRadius(AppStyles.BorderRadius.medium).clipped()
                case .failure:
                    ZStack { AppColors.backgroundLightGray; Image(systemName: "photo.on.rectangle.angled").resizable().aspectRatio(contentMode: .fit).foregroundColor(AppColors.textMuted.opacity(0.6)).padding(AppStyles.Spacing.large) }
                        .frame(height: 150).cornerRadius(AppStyles.BorderRadius.medium)
                @unknown default: EmptyView()
                }
            }
            .frame(height: 150) // Höhe des Bildbereichs
            .clipped() // Wichtig, wenn das Bild Ecken hat und der Container nicht
            .padding(.bottom, AppStyles.Spacing.small)

            // MARK: - Produktname
            Text(product.name)
                .font(AppFonts.montserrat(size: AppFonts.Size.smallBody, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true) // Erlaubt Umbruch

            Spacer() // Drückt Preis und Herz nach unten

            // MARK: - Preis und Herz-Button (NEUE ANORDNUNG)
            HStack(alignment: .bottom) { // .bottom für konsistente Ausrichtung
                // Preis-VStack
                VStack(alignment: .leading, spacing: 0) {
                    let currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? AppConfig.WooCommerce.defaultCurrencySymbol
                    Text("\(currencySymbol)\(product.price)")
                        .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold))
                        .foregroundColor(AppColors.price)
                    
                    if product.onSale && !product.regularPrice.isEmpty && product.regularPrice != product.price {
                        Text("\(currencySymbol)\(product.regularPrice)")
                            .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .regular))
                            .foregroundColor(AppColors.textMuted)
                            .strikethrough(true, color: AppColors.textMuted)
                    }
                }
                
                Spacer() // Schiebt den Herz-Button nach rechts

                // Herz-Button für Wunschliste
                Button {
                    // Einfach den Status umschalten. WishlistState kümmert sich darum,
                    // ob lokal oder in Firestore gespeichert wird.
                    wishlistState.toggleWishlistStatus(for: product.id)
                } label: {
                    Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                        .font(.title3) // Passende Größe für die Karte
                        .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? AppColors.wishlistIcon : AppColors.textMuted)
                        // Optional: Kleiner Hintergrund für das Herz, falls nötig
                        // .padding(AppStyles.Spacing.xSmall / 1.5)
                        // .background(.ultraThinMaterial, in: Circle())
                }
                // .padding(.leading, AppStyles.Spacing.small) // Etwas Abstand zum Preis, falls sie zu nah sind
            }
            .padding(.top, AppStyles.Spacing.xSmall) // Kleiner Abstand über dem Preis/Herz-Block
        }
        .padding(AppStyles.Spacing.small) // Innenabstand der gesamten Karte
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        .appShadow(AppStyles.Shadows.small)
        // Der .sheet Modifier für Auth ist hier nicht mehr nötig für die Herz-Funktion
    }
}

// (Die String asURL() Extension sollte global sein)
