import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    
    var body: some View {
        NavigationStack {
            // NEW: Wir verwenden eine ZStack, um eine globale Hintergrundfarbe
            // für die gesamte Ansicht festzulegen.
            ZStack {
                // Die unterste Ebene ist unsere Seitenhintergrundfarbe.
                AppColors.backgroundPage.ignoresSafeArea()

                Group {
                    if viewModel.isLoading && viewModel.categories.isEmpty {
                        // UPDATED: Ein ansprechenderer Ladeindikator mit App-Farben und Schriftarten.
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(AppColors.primary) // Färbt den Ladekreis
                            Text("Lade Kategorien...")
                                .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
                                .foregroundColor(AppColors.textMuted)
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        // Hier könnte man auch eine dedizierte ErrorView erstellen.
                        Text(errorMessage)
                            .foregroundColor(AppColors.error)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if viewModel.categories.isEmpty {
                        // UPDATED: Der Leer-Zustand wird ebenfalls an das Design angepasst.
                        Text("Keine Kategorien gefunden.")
                            .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
                            .foregroundColor(AppColors.textMuted)
                    } else {
                        List {
                            ForEach(viewModel.categories) { wooCategory in
                                NavigationLink(value: wooCategory) {
                                    ProductCategoryRow(category: wooCategory)
                                }
                                // Diese Einstellungen sind bereits sehr gut.
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear) // Lässt den ZStack-Hintergrund durchscheinen
                            }
                        }
                        .listStyle(.plain)
                        // UPDATED: Stellt sicher, dass der List-Hintergrund transparent ist.
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle("Shop") // Bleibt für Barrierefreiheit und als Fallback
                .navigationBarTitleDisplayMode(.inline) // Sorgt für konsistentes Verhalten
                .toolbar {
                    // NEW: Wir passen den Titel in der Toolbar an, um unsere Schriftart zu verwenden.
                    ToolbarItem(placement: .principal) {
                        Text("Shop")
                            .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                            .foregroundColor(AppColors.textHeadings)
                    }
                }
                .onAppear {
                    if viewModel.categories.isEmpty {
                        viewModel.fetchMainCategories()
                    }
                }
                // Die Navigationsziele bleiben unberührt, die Logik ist perfekt.
                .navigationDestination(for: WooCommerceCategory.self) { category in
                    if let appNavItem = AppNavigationData.findItem(forMainCategorySlug: category.slug) {
                        SubCategoryListView(
                            selectedMainCategoryAppItem: appNavItem,
                            parentWooCommerceCategoryID: category.id
                        )
                    }
                }
                .navigationDestination(for: WooCommerceProduct.self) { product in
                    ProductDetailView(productSlug: product.slug, initialProductData: product)
                }
            }
        }
    }
}
