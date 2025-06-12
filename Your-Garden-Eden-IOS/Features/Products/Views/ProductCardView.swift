// Features/Products/Views/ProductCardView.swift

import SwiftUI

struct ProductCardView: View {
    let product: WooCommerceProduct

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Das Bild ist jetzt das einzige Element im oberen Bereich.
            productImage
            
            // Text-Inhalt mit Padding
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name.strippingHTML())
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(minHeight: 45, alignment: .top)

                Text((product.priceHtml ?? product.price).strippingHTML())
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }

    private var productImage: some View {
        AsyncImage(url: product.images.first?.src.asURL()) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.systemGray4))
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(Color(UIColor.systemGray6))
            default:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 180)
            }
        }
        .frame(height: 180)
        .clipped()
    }
}
