import SwiftUI

struct RelatedProductsView: View {
    // GEÄNDERT: Akzeptiert wieder die sichere Wrapper-Struktur.
    let products: [IdentifiableDisplayProduct]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Das könnte Ihnen auch gefallen")
                .font(.title3.weight(.bold))
                .foregroundColor(AppColors.textHeadings)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Die ForEach-Schleife ist jetzt sicher gegen doppelte IDs.
                    ForEach(products) { identifiableProduct in
                        NavigationLink(value: identifiableProduct.product) {
                            ProductCardView(product: identifiableProduct.product)
                                .frame(width: 160)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(AppColors.backgroundLightGray.opacity(0.5))
    }
}
