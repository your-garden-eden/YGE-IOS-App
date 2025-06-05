import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(
            productSlug: productSlug,
            initialProductData: initialProductData
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let product = viewModel.product {
                    // Hauptinhalt der Seite, aufgeteilt in Komponenten
                    productImagesView(images: product.images)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        productTitleView(name: product.name)
                        productPriceView(priceHTML: product.priceHtml)
                        // Weitere Komponenten hier...
                        // z.B. productDescriptionView, productVariationSelector, etc.
                    }
                    .padding()
                    
                } else if viewModel.isLoading {
                    ProgressView("Lade Produktdetails...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .padding()
                }
            }
        }
        .navigationTitle(viewModel.product?.name ?? "Produktdetail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Lade die vollständigen Details, wenn die Ansicht erscheint
            await viewModel.fetchProductDetails()
        }
    }

    // MARK: - Subviews (Aufteilung der Komplexität)

    private func productImagesView(images: [WooCommerceImage]) -> some View {
        TabView {
            ForEach(images) { image in
                // Annahme: Du hast eine Kingfisher- oder AsyncImage-Implementierung
                // Hier als Platzhalter:
                AsyncImage(url: URL(string: image.src)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFit()
                    case .failure:
                        Image(systemName: "photo.fill").font(.largeTitle)
                    default:
                        ProgressView()
                    }
                }
            }
        }
        .tabViewStyle(.page)
        .frame(height: 300)
    }

    private func productTitleView(name: String) -> some View {
        Text(name)
            .font(.largeTitle)
            .fontWeight(.bold)
    }

    private func productPriceView(priceHTML: String?) -> some View {
        // Annahme: Du hast eine Methode, um HTML zu parsen oder zu anzeigen.
        // Hier als einfacher Text-Platzhalter:
        Text(priceHTML?.strippingHTML() ?? "Preis nicht verfügbar")
            .font(.title2)
            .foregroundStyle(AppColors.price)
    }
}
