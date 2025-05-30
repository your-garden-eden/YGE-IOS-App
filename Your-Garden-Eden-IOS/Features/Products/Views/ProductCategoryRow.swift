//
//  ProductCategoryRow.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 29.05.25.
//


// ProductCategoryRow.swift
// Speicherort: Idealerweise in einem Ordner für wiederverwendbare Komponenten oder
// spezifisch unter Core/Categories/Views/, wenn sie nur dort verwendet wird.
// Für dieses Beispiel nehmen wir an, sie liegt dort, wo sie von CategoryListView (Core/Categories/Views)
// leicht gefunden werden kann, oder du passt den Import entsprechend an.

import SwiftUI

struct ProductCategoryRow: View {
    let category: WooCommerceCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Hauptcontainer der Karte
            ZStack(alignment: .bottomLeading) {
                // MARK: - Kategoriebild
                Group { // Gruppe für bedingte Bildanzeige
                    if let imageUrlString = category.image?.src, let imageUrl = URL(string: imageUrlString) {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(AppColors.backgroundLightGray)
                                    .aspectRatio(16/9, contentMode: .fit) // Seitenverhältnis für Banner
                                    // .frame(height: 180) // Feste Höhe alternativ
                                    .overlay(ProgressView().tint(AppColors.primary))
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fill) // Füllt den Bereich
                                    .layoutPriority(-1) // Hilft bei der Größenanpassung im ZStack
                            case .failure:
                                Rectangle()
                                    .fill(AppColors.backgroundLightGray)
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .overlay(
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 40))
                                            .foregroundColor(AppColors.textMuted.opacity(0.7))
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        // Fallback, wenn kein Bild vorhanden ist
                        Rectangle()
                            .fill(AppColors.backgroundLightGray)
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.textMuted.opacity(0.7))
                            )
                    }
                }
                .frame(maxWidth: .infinity) // Nimmt die volle Breite ein
                .aspectRatio(16/9, contentMode: .fit) // Definiere ein Seitenverhältnis, z.B. 16:9 für Banner
                // .frame(height: 180) // Alternative: Feste Höhe, wenn Seitenverhältnis nicht gewünscht
                .clipped() // Wichtig, wenn .fill und aspectRatio verwendet wird

                // MARK: - Text-Overlay
                VStack(alignment: .leading) { // VStack für den Text-Overlay-Inhalt
                    Spacer() // Drückt den Text nach unten
                    HStack { // HStack für Text und ggf. Chevron oder Count
                        Text(category.name)
                            .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .bold))
                            .foregroundColor(AppColors.textOnPrimary)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1) // Schatten für Textlesbarkeit
                            .lineLimit(2)
                            .padding([.leading, .bottom], AppStyles.Spacing.medium)
                            .padding(.trailing, AppStyles.Spacing.small) // Etwas Platz zum Rand oder Chevron

                        Spacer() // Nimmt den restlichen Platz ein

                        // Optional: Chevron als Indikator für Klickbarkeit,
                        // da der NavigationLink die ganze Zelle umspannt.
                        // Image(systemName: "chevron.right")
                        //    .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .semibold))
                        //    .foregroundColor(AppColors.textOnPrimary.opacity(0.8))
                        //    .padding([.trailing, .bottom], AppStyles.Spacing.medium)
                    }
                }
                .background(
                    LinearGradient( // Gradient für bessere Textlesbarkeit
                        gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)]),
                        startPoint: .top, // Oben transparent
                        endPoint: .bottom  // Unten dunkler
                    )
                    .padding(.top, -50) // Erlaube dem Gradienten, etwas höher zu starten für sanfteren Übergang
                )
            }
        }
        .background(AppColors.backgroundComponent) // Hintergrund der gesamten Karte
        .cornerRadius(AppStyles.BorderRadius.large) // Abgerundete Ecken für die gesamte Karte
        .appShadow(AppStyles.Shadows.medium) // Schatten für die gesamte Karte
    }
}

// Preview Provider für ProductCategoryRow
struct ProductCategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        // Beispiel-Kategorie für die Preview
        let exampleImage = WooCommerceImage(id: 1, dateCreated: "2023-01-01T10:00:00", dateCreatedGmt: "2023-01-01T10:00:00Z", dateModified: "2023-01-01T10:00:00", dateModifiedGmt: "2023-01-01T10:00:00Z", src: "https://via.placeholder.com/600x338/A1B48A/FFFFFF?text=Gartenmöbel", name: "Beispielbild", alt: "Ein Beispiel", position: 0)
        
        let exampleCategory = WooCommerceCategory(
            id: 1,
            name: "Gartenmöbel",
            slug: "gartenmoebel",
            parent: 0,
            description: "Hochwertige und stilvolle Möbel für Ihren Garten und Außenbereich.",
            display: "default",
            image: exampleImage, // Hier das Beispielbild verwenden
            menuOrder: 1,
            count: 42
        )
        
        let categoryWithoutImage = WooCommerceCategory(
            id: 2,
            name: "Sonnenschutz ohne Bild",
            slug: "sonnenschutz",
            parent: 0,
            description: "Alles für den perfekten Schutz vor der Sonne.",
            display: "default",
            image: nil, // Kein Bild
            menuOrder: 2,
            count: 15
        )

        ScrollView {
            VStack(spacing: 20) {
                ProductCategoryRow(category: exampleCategory)
                ProductCategoryRow(category: categoryWithoutImage)
            }
            .padding()
        }
        .background(AppColors.backgroundPage)
    }
}