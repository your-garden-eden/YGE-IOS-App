import SwiftUI

struct RelatedProductsView: View {
    let products: [IdentifiableDisplayProduct]

    var body: some View {
        // Die View ist jetzt nur noch die ScrollView selbst.
        // Der Titel und der Hintergrund werden von der aufrufenden View (ProductDetailView) gesteuert.
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(products) { identifiableProduct in
                    // NavigationLink ist bereits in der ProductDetailView definiert,
                    // aber hier ist er auch okay, falls die View woanders genutzt wird.
                    NavigationLink(value: identifiableProduct.product) {
                        ProductCardView(product: identifiableProduct.product)
                            .frame(width: 160)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        // KORREKTUR: Gib der ScrollView eine feste Höhe, damit sie nicht kollabiert.
        // Passe die Höhe bei Bedarf an das Design deiner ProductCardView an.
        .frame(height: 240)
    }
}
