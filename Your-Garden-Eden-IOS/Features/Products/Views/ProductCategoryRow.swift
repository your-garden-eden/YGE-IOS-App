// Path: Your-Garden-Eden-IOS/Features/Categories/Views/ProductCategoryRow.swift
// FINALE, VOLLSTÄNDIGE VERSION

import SwiftUI

struct ProductCategoryRow: View {
    let label: String
    let imageUrl: URL?              // Für remote Bilder von der API
    let localImageFilename: String? // Für lokale Fallback-Bilder aus App-Assets

    var body: some View {
        ZStack(alignment: .center) {
            // Die Bildlogik ist für maximale Klarheit in eine eigene private View ausgelagert.
            imageContentView

            // Dunkler Schleier für bessere Lesbarkeit des Textes
            Rectangle()
                .fill(.black.opacity(0.40))

            // Der Kategorie-Titel
            Text(label)
                .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
        }
        .frame(height: 150)
        .background(AppColors.backgroundLightGray) // Wird sichtbar, wenn kein Bild lädt
        .cornerRadius(AppStyles.BorderRadius.large)
        .clipped()
    }

    // Diese @ViewBuilder-Funktion enthält die robuste Logik zur Bildanzeige.
    // Sie stellt sicher, dass immer etwas Sinnvolles angezeigt wird.
    @ViewBuilder
    private var imageContentView: some View {
        // 1. VERSUCH: Lade das remote Bild via URL.
        AsyncImage(url: imageUrl) { phase in
            switch phase {
            case .success(let image):
                // ERFOLG: Remote-Bild wird angezeigt.
                image.resizable().aspectRatio(contentMode: .fill)
            
            case .failure, .empty:
                // FEHLSCHLAG: Remote-Bild konnte nicht geladen werden.
                // 2. VERSUCH: Lade das lokale Fallback-Bild.
                if let filename = localImageFilename, !filename.isEmpty {
                    Image(filename)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // 3. ULTIMATIVER FALLBACK: Wenn alles fehlschlägt, zeige ein Platzhalter-Icon.
                    placeholderImage
                }
                
            @unknown default:
                EmptyView()
            }
        }
    }

    // Eine saubere Platzhalter-View.
    @ViewBuilder
    private var placeholderImage: some View {
        ZStack {
            AppColors.backgroundLightGray
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .foregroundColor(AppColors.textMuted.opacity(0.5))
                .padding(30)
        }
    }
}
