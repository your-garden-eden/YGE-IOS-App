import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel: ProductListViewModel
    private var gridItemLayout = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    init(categoryId: Int, categoryName: String) {
        _viewModel = StateObject(wrappedValue: ProductListViewModel(categoryId: categoryId, categoryName: categoryName))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Lade Produkte...")
            } else if let errorMessage = viewModel.errorMessage {
                 VStack { Text("Fehler: \(errorMessage)"); Button("Erneut") { viewModel.loadProducts() } }
            } else if $viewModel.products.isEmpty {
                Text("Keine Produkte in dieser Kategorie gefunden. Ladefunktion ist ggf. deaktiviert.")
                    .foregroundColor(.secondary)
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, spacing: 20) {
                        ForEach(viewModel.products) { product in
                            NavigationLink(value: product) {
                                ProductCardView(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(viewModel.categoryName)
        .onAppear {
            if $viewModel.products.isEmpty && !viewModel.isLoading { // Nur laden, wenn leer und nicht schon lädt
                viewModel.loadProducts()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { viewModel.loadProducts() } label: { Image(systemName: "arrow.clockwise") }
            }
        }
        .navigationDestination(for: WooCommerceProduct.self) { product in
            Text("Detailansicht für \(product.name) (Platzhalter)") // Später: ProductDetailView(product: product)
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
   static var previews: some View {
       NavigationStack {
           ProductListView(categoryId: WooCommerceCategory.placeholder.id, // Nutze Placeholder-Daten
                           categoryName: WooCommerceCategory.placeholder.name)
       }
   }
}
