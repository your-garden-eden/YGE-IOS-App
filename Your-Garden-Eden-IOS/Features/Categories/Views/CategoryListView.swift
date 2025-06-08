import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPage.ignoresSafeArea()
                contentView
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.categories.isEmpty {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if viewModel.categories.isEmpty && !viewModel.isLoading {
            emptyView
        } else {
            categoryList
        }
    }
    
    // MARK: - List
    
    private var categoryList: some View {
        List {
            // Wir iterieren direkt über die Kategorien vom ViewModel.
            ForEach(viewModel.categories) { wooCategory in
                // Wir suchen das passende lokale Navigationselement.
                if let navItem = AppNavigationData.findItem(forMainCategorySlug: wooCategory.slug) {
                    // Wenn wir es finden, erstellen wir den NavigationLink.
                    NavigationLink(value: wooCategory) {
                        // Wir übergeben die Daten direkt an die ProductCategoryRow.
                        ProductCategoryRow(
                            label: navItem.label, // Der korrekte Text
                            imageUrl: wooCategory.image?.src.asURL(), // Die API-Bild-URL
                            localImageFilename: navItem.imageFilename // Das lokale Fallback-Bild
                        )
                    }
                }
                // Wenn kein navItem gefunden wird, wird für diese API-Kategorie keine Zeile erstellt.
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Helper Views
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView().tint(AppColors.primary)
            Text("Lade Kategorien...")
                .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
                .foregroundColor(AppColors.textMuted)
        }
    }
    
    private func errorView(message: String) -> some View {
        Text(message)
            .foregroundColor(AppColors.error)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private var emptyView: some View {
        Text("Keine Kategorien gefunden.")
            .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
            .foregroundColor(AppColors.textMuted)
    }
}
