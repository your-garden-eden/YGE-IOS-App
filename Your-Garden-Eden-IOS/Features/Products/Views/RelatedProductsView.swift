import SwiftUI

struct RelatedProductsView: View {
    let products: [WooCommerceProduct]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Das könnte Ihnen auch gefallen")
                .font(.title3.weight(.bold))
                .foregroundColor(AppColors.textHeadings)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(products) { product in
                        // Wir verwenden unsere existierende ProductCardView.
                        // Wir machen sie zu einem Navigationslink, damit man direkt zum Produkt springen kann.
                        NavigationLink(value: product) {
                            ProductCardView(product: product)
                                .frame(width: 160) // Feste Breite für eine konsistente Darstellung
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        // Ein leichter Hintergrund, um die Sektion von der Haupt-Seitenfarbe abzuheben.
        // Falls Ihre backgroundPage und backgroundLightGray gleich sind, können Sie dies anpassen.
        .background(AppColors.backgroundLightGray.opacity(0.5))
    }
}
