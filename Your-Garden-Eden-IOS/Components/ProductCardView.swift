import SwiftUI

struct ProductCardView: View {
    var product: WooCommerceProduct // Diese Zeile stellt sicher, dass die View ein Produkt erwartet

    var body: some View {
        VStack(alignment: .leading) {
            // Bildanzeige
            if let firstImage = product.images.first, let imageUrl = URL(string: firstImage.src) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 150) // Gib dem ProgressView eine definierte Höhe
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fit) // .fit, damit das ganze Bild sichtbar ist
                    case .failure:
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 150) // Definiere eine feste Höhe für den Bildbereich
                .clipped() // Verhindert, dass das Bild über den Rahmen hinausgeht
            } else {
                Image(systemName: "photo.on.rectangle.angled") // Platzhalter, wenn kein Bild vorhanden
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .frame(height: 150)
            }
            
            // Produktname
            Text(product.name)
                .font(.headline)
                .lineLimit(2) // Begrenzt den Namen auf maximal 2 Zeilen
                .padding(.top, 4) // Kleiner Abstand nach oben

            // Preis
            Text("€\(product.price)") // Du könntest hier auch product.priceHtml verwenden, falls es formatiert ist
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 4) // Kleiner Abstand nach unten
        }
        .padding(8) // Innenabstand für den gesamten Inhalt der Karte
        .background(Color(UIColor.systemGray6)) // Heller Hintergrund für die Karte
        .cornerRadius(10) // Abgerundete Ecken
        .shadow(radius: 2, x: 0, y: 1) // Subtiler Schatten für Tiefe (optional)
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Stellt sicher, dass WooCommerceProduct.placeholder in deinem WooCommerceProduct.swift definiert ist
        ProductCardView(product: .placeholder)
            .previewLayout(.fixed(width: 200, height: 280)) // Beispielhafte Größe für eine Produktkarte in der Preview
            .padding() // Etwas Abstand um die Karte in der Preview
    }
}
