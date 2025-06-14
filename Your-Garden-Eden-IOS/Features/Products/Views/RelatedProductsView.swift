// Path: Your-Garden-Eden-IOS/Features/Products/Views/RelatedProductsView.swift

import SwiftUI

// Hilfsstruktur, um die Produkte für ForEach identifizierbar zu machen.
struct IdentifiableDisplayProduct: Identifiable {
    let id = UUID()
    let product: WooCommerceProduct
}

struct RelatedProductsView: View {
    let products: [IdentifiableDisplayProduct]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppStyles.Spacing.medium) {
                ForEach(products) { identifiableProduct in
                    NavigationLink(value: identifiableProduct.product) {
                        ProductCardView(product: identifiableProduct.product)
                            .frame(width: 160)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, AppStyles.Spacing.xSmall)
        }
    }
}
