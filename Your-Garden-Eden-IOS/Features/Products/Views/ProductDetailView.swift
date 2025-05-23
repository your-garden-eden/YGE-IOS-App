// Your-Garden-Eden-IOS/Features/Products/Views/ProductDetailView.swift

import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedImageIndex: Int = 0

    // Initializer bleibt gleich
    init(productId: Int, initialProductData: WooCommerceProduct? = nil, productName: String? = nil) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productId: productId, initialProductData: initialProductData))
    }

    // Private computed property für die Kaufbarkeit
    // Wichtig: Diese Property muss Zugriff auf `viewModel.product` haben.
    private var canPurchaseProduct: Bool {
        guard let product = viewModel.product else {
            return false // Wenn kein Produkt geladen ist, kann es nicht gekauft werden
        }
        return product.purchasable && (product.stockStatus != "outofstock" || product.backordersAllowed)
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.product == nil {
                // ... (Ladeanzeige) ...
            } else if let errorMessage = viewModel.errorMessage, viewModel.product == nil {
                // ... (Fehleranzeige) ...
            } else if let product = viewModel.product { // Hier wird 'product' für den Body verfügbar gemacht
                VStack(alignment: .leading, spacing: 16) {
                    // ... (productImageGallery, Name, Preis, Kurzbeschreibung, Lagerstatus, Mengenauswahl) ...
                    // Die vorherigen Teile bleiben wie in der letzten funktionierenden Version

                    // "In den Warenkorb"-Button - Verwendung der computed property
                    Button(action: viewModel.addToCart) {
                        Label("In den Warenkorb", systemImage: "cart.badge.plus")
                            .fontWeight(.semibold)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(canPurchaseProduct ? Color.accentColor : Color.gray) // Verwende computed property
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!canPurchaseProduct) // Verwende computed property // Zeile ~86 (ungefähr)
                    .padding(.horizontal)          // Zeile ~87
                    .padding(.top)                 // Zeile ~88

                    // Lange Beschreibung
                    if !product.description.isEmpty {
                        DisclosureGroup("Produktbeschreibung") {
                            Text(stripHtml(from: product.description))
                                .font(.body)
                                .padding(.top, 5)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
            } else {
                Text("Produktdetails nicht verfügbar.")
                    .padding(.top, 50)
            }
        }
        // ... (Rest der View: navigationTitle, onAppear, stripHtml, productImageGallery) ...
        // Die productImageGallery und stripHtml Funktionen bleiben wie zuvor.
    }

    // stripHtml Funktion bleibt hier
    private func stripHtml(from text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    // productImageGallery Funktion bleibt hier
    @ViewBuilder
    private func productImageGallery(images: [WooCommerceImage]) -> some View {
        // ... (Implementierung wie zuvor)
        if !images.isEmpty {
            TabView(selection: $selectedImageIndex) {
                ForEach(images.indices, id: \.self) { index in
                    if let imageUrl = URL(string: images[index].src) {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty: ProgressView()
                            case .success(let image): image.resizable().aspectRatio(contentMode: .fit)
                            case .failure: Image(systemName: "photo.on.rectangle.angled").resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray)
                            @unknown default: EmptyView()
                            }
                        }
                        .tag(index)
                    } else {
                         Image(systemName: "photo.questionmark.dashed")
                            .resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: images.count > 1 ? .automatic : .never))
            .frame(height: 300)
            .background(Color(UIColor.systemGray6))
        } else {
            Image(systemName: "photo.on.rectangle.angled")
                .resizable().aspectRatio(contentMode: .fit)
                .frame(height: 200).foregroundColor(.gray).frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray6))
        }
    }
}

// Preview Provider bleibt gleich
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductDetailView(productId: WooCommerceProduct.placeholder.id, initialProductData: WooCommerceProduct.placeholder)
        }
    }
}
