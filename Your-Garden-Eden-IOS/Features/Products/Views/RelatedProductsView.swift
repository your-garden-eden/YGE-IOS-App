// Features/Products/Views/RelatedProductsView.swift

import SwiftUI

struct RelatedProductsView: View {
    // Die View erhält die Liste der Produkte, die sie anzeigen soll.
    let products: [IdentifiableDisplayProduct]

    var body: some View {
        // Horizontale Scroll-Ansicht für die Produktkarten
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Iteriert durch die eindeutig identifizierbaren Produkte
                ForEach(products) { identifiableProduct in
                    
                    // Jede Karte ist ein Navigationslink zur jeweiligen Detailseite.
                    // Der 'value' ist das 'WooCommerceProduct', das Hashable ist.
                    NavigationLink(value: identifiableProduct.product) {
                        
                        // Die ProductCardView zeigt das eigentliche Produkt an.
                        ProductCardView(product: identifiableProduct.product)
                            .frame(width: 160) // Eine feste Breite für die Karten im Karussell
                        
                    }
                    .buttonStyle(.plain) // Verhindert, dass der ganze Link blau eingefärbt wird
                }
            }
            .padding(.horizontal) // Fügt seitlichen Abstand hinzu
            .padding(.vertical, 8) // Fügt etwas Abstand oben/unten hinzu
        }
    }
}
