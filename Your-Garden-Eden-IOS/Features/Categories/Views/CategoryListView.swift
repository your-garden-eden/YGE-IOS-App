import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    
    var body: some View {
        // KORREKTUR 1: Dies ist die EINZIGE NavigationStack für den gesamten Shop-Tab.
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    ProgressView("Lade Kategorien...")
                } else if viewModel.errorMessage != nil {
                    // ... (dein existierendes, gutes Fehler-Handling)
                } else if viewModel.categories.isEmpty {
                    Text("Keine Kategorien gefunden.")
                } else {
                    List {
                        ForEach(viewModel.categories) { wooCategory in
                            // Wir übergeben das gesamte Kategorie-Objekt als Navigationswert.
                            NavigationLink(value: wooCategory) {
                                ProductCategoryRow(category: wooCategory)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Shop")
            .onAppear {
                if viewModel.categories.isEmpty {
                    viewModel.fetchMainCategories()
                }
            }
            // KORREKTUR 2: ALLE Navigationsziele für diesen Stack werden hier deklariert.
            
            // Ziel 1: Wenn ein `WooCommerceCategory`-Objekt übergeben wird, zeige die SubCategoryListView.
            .navigationDestination(for: WooCommerceCategory.self) { category in
                if let appNavItem = AppNavigationData.findItem(forMainCategorySlug: category.slug) {
                    SubCategoryListView(
                        selectedMainCategoryAppItem: appNavItem,
                        parentWooCommerceCategoryID: category.id
                    )
                }
            }
            
            // Ziel 2: Wenn ein `WooCommerceProduct`-Objekt übergeben wird, zeige die ProductDetailView.
            // Dies fängt die Navigation von JEDER untergeordneten View (z.B. SubCategoryListView) ab.
            .navigationDestination(for: WooCommerceProduct.self) { product in
                ProductDetailView(productSlug: product.slug, initialProductData: product)
            }
        }
    }
}
