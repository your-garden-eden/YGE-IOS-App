// YGE-IOS-App/Features/Products/Views/ProductRowView.swift
// (Stelle sicher, dass der Dateiname und Pfad korrekt sind)

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
                             .aspectRatio(contentMode: .fill) // .fill für bessere Thumbnail-Optik
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
                            .frame(width: 50, height: 50) // Icon Größe
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
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold)) // Montserrat für Produktnamen
                    .foregroundColor(AppColors.textHeadings)
                    .lineLimit(2) // Produktnamen können lang sein

                // Kurzbeschreibung (optional, falls vorhanden und gewünscht)
                if !product.shortDescription.isEmpty {
                    Text(product.shortDescription.strippingHTML())
                        .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .regular))
                        .foregroundColor(AppColors.textMuted)
                        .lineLimit(2)
                        .padding(.top, AppStyles.Spacing.xxSmall)
                }
                
                Spacer() // Drückt Preis und Status nach unten

                // Preis und Lagerstatus
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: AppStyles.Spacing.xxSmall) {
                        // Preis
                        Text(product.price + (product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? " €")) // Währungssymbol, wenn vorhanden
                            .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold))
                            .foregroundColor(AppColors.price) // Spezifische Preisfarbe

                        // Regulärer Preis, wenn Sale
                        if product.onSale, let regularPrice = product.regularPrice, regularPrice != product.price, !regularPrice.isEmpty {
                            Text(regularPrice + (product.metaData.first(where: {$0.key == "_currency_symbol"})?.value as? String ?? " €"))
                                .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .regular))
                                .foregroundColor(AppColors.textMuted)
                                .strikethrough()
                        }
                    }
                    
                    Spacer() // Schiebt Lagerstatus nach rechts
                    
                    // Lagerstatus (vereinfacht)
                    if let stockStatus = product.stockStatus {
                        Text(stockStatus == .instock ? "Auf Lager" : (product.backordersAllowed ? "Lieferbar" : "Ausverkauft"))
                            .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .medium))
                            .foregroundColor(stockStatus == .instock ? AppColors.inStock : (product.backordersAllowed ? AppColors.warning : AppColors.error))
                            .padding(.horizontal, AppStyles.Spacing.small)
                            .padding(.vertical, AppStyles.Spacing.xxSmall)
                            .background((stockStatus == .instock ? AppColors.inStock : (product.backordersAllowed ? AppColors.warning : AppColors.error)).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(minHeight: 70) // Mindesthöhe für den Textbereich, um Layout zu stabilisieren
        }
        // Padding wird von der Liste oder Section gehandhabt, oder hier, wenn ein Karten-Look gewünscht ist.
        // Für Listen ist es oft besser, kein horizontales Padding direkt in der Row zu haben.
        // .padding(.vertical, AppStyles.Spacing.small)
    }
}

struct ProductRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Du benötigst eine WooCommerceProduct.placeholderSimple() oder ähnliche Mock-Daten
        // um die Preview sinnvoll zu gestalten.
        // WooCommerceProduct.placeholderSimple()
        let mockProduct = WooCommerceProduct(
            id: 1, name: "Moderne Gartenliege 'Relaxo' mit Aluminiumrahmen und Textilene-Bespannung",
            slug: "gartenliege-relaxo", permalink: "", dateCreated: "", dateCreatedGmt: "",
            dateModified: nil, dateModifiedGmt: nil, type: .simple, status: "publish", featured: false,
            catalogVisibility: "visible", description: "Lange Beschreibung...",
            shortDescription: "Super bequeme Liege für entspannte Stunden im Freien. Wetterfest und langlebig.",
            sku: "GL-RX-001", price: "149.99", regularPrice: "199.99", salePrice: "149.99", priceHtml: nil,
            dateOnSaleFrom: nil, dateOnSaleFromGmt: nil, dateOnSaleTo: nil, dateOnSaleToGmt: nil,
            onSale: true, purchasable: true, totalSales: 12, virtual: false, downloadable: false,
            externalUrl: nil, buttonText: nil, taxStatus: "taxable", taxClass: nil,
            manageStock: true, stockQuantity: 5, stockStatus: .instock, backorders: "no",
            backordersAllowed: false, backordered: false, lowStockAmount: 2, soldIndividually: false,
            weight: "15", dimensions: WooCommerceProductDimension(length: "190", width: "70", height: "30"),
            shippingRequired: true, shippingTaxable: true, shippingClass: nil, shippingClassId: 0,
            reviewsAllowed: true, averageRating: "4.5", ratingCount: 23, relatedIds: [],
            upsellIds: [], crossSellIds: [], parentId: 0, purchaseNote: nil,
            categories: [WooCommerceCategoryRef(id: 1, name: "Gartenmöbel", slug: "gartenmoebel")],
            tags: [], images: [WooCommerceImage(id: 1, dateCreated: nil, dateCreatedGmt: nil, dateModified: nil, dateModifiedGmt: nil, src: "https://your-garden-eden-4ujzpfm5qt.live-website.com/wp-content/uploads/2024/03/pexels-lisa-fotios-1090638-scaled.jpg", name: "Liege", alt: "Gartenliege", position: 0)],
            attributes: [], defaultAttributes: [], variations: [], groupedProducts: nil, menuOrder: 0, metaData: [WooCommerceMetaData(id:1, key: "_currency_symbol", value: .string("€"))]
        )

        return Group {
            ProductRowView(product: mockProduct)
                .padding() // Um die Row in der Preview besser zu sehen
                .previewLayout(.sizeThatFits)
            
            List { // Zeige es in einer Liste, um List-Styling zu sehen
                ProductRowView(product: mockProduct)
                ProductRowView(product: {
                    let p = mockProduct
                    // Umbenennen für Testzwecke, falls WooCommerceProduct ein struct ist
                    // p.name = "Ein anderes Produkt ohne Sale"
                    // p.onSale = false
                    // p.stockStatus = .outofstock
                    // p.backordersAllowed = false
                    return p // Hier müsste man eine Kopie erstellen und modifizieren
                }())
            }
        }
    }
}
