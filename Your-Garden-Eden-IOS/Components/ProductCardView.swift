// YGE-IOS-App/Features/Products/Views/ProductCardView.swift (oder wo du sie ablegst)
import SwiftUI

struct ProductCardView: View {
    var product: WooCommerceProduct // Erwartet die existierende WooCommerceProduct-Struktur

    var body: some View {
        VStack(alignment: .leading) {
            // Bildanzeige
            if let firstImage = product.images.first, let imageUrl = URL(string: firstImage.src) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ZStack { // ZStack für Hintergrundfarbe während des Ladens
                            Color(UIColor.systemGray5) // Heller Platzhalter-Hintergrund
                            ProgressView()
                        }
                        .frame(height: 150)
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fit) // .fit ist oft besser für Produktbilder
                    case .failure:
                        ZStack { // ZStack für Hintergrundfarbe bei Fehler
                            Color(UIColor.systemGray5)
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                                .padding(30) // Etwas Padding für das Icon
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 150)
                .clipped()
            } else {
                ZStack { // ZStack für Hintergrundfarbe bei fehlendem Bild
                    Color(UIColor.systemGray5)
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .padding(30) // Etwas Padding für das Icon
                }
                .frame(height: 150)
            }
            
            // Produktname
            Text(product.name)
                .font(.headline)
                .lineLimit(2)
                .padding(.top, 8) // Etwas mehr Abstand
                .padding(.horizontal, 4)

            // Preis
            // Extrahiere Währungssymbol sicherer, falls MetaData nicht vorhanden oder anders formatiert
            let currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"
            Text("\(currencySymbol)\(product.price)")
                .font(.subheadline)
                .fontWeight(.semibold) // Preis etwas hervorheben
                .foregroundColor(.primary) // Oder deine Akzentfarbe
                .padding(.horizontal, 4)
            
            Spacer() // Drückt den Inhalt nach oben, falls die Karte mehr Platz hat
        }
        .padding(12) // Konsistenter Innenabstand
        .background(Color(UIColor.systemBackground)) // Systemhintergrund für Light/Dark Mode
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2) // Subtilerer Schatten
    }
}

// ---- HIER IST DIE WICHTIGE ÄNDERUNG ----
// Der Placeholder wird als Extension zur existierenden WooCommerceProduct-Struktur hinzugefügt.
// Diese Extension kann in derselben Datei wie ProductCardView sein,
// oder in WooCommerceProduct.swift, oder in einer eigenen Datei WooCommerceProduct+Placeholders.swift.



