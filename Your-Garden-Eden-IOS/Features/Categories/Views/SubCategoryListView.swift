import SwiftUI

struct SubCategoryListView: View {
    @StateObject private var viewModel: SubCategoryViewModel
    @State private var selectedSubCategory: DisplayableSubCategory? = nil

    init(selectedMainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        _viewModel = StateObject(wrappedValue: SubCategoryViewModel(
            mainCategoryAppItem: selectedMainCategoryAppItem,
            parentWooCommerceCategoryID: parentWooCommerceCategoryID
        ))
    }

    var body: some View {
        // WICHTIG: KEINE NavigationStack hier!
        Group {
            if let subCategory = selectedSubCategory {
                productListView(for: subCategory)
            } else {
                subCategorySelectionView
            }
        }
        // KORREKTUR: Der .navigationDestination-Modifier wurde von hier ENTFERNT.
        // Die Verantwortung liegt nun bei der CategoryListView.
    }

    // ... subCategorySelectionView bleibt unverändert ...
    private var subCategorySelectionView: some View {
        // ...
        List(viewModel.displayableSubCategories) { subCat in
            Button(action: {
                selectedSubCategory = subCat
                Task {
                    await viewModel.loadProducts(for: subCat, initialLoad: true)
                }
            }) {
                SubCategoryRow(subCategory: subCat)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(.plain)
        .navigationTitle(viewModel.mainCategoryAppItem.label)
        .task {
            if viewModel.displayableSubCategories.isEmpty {
                await viewModel.loadSubCategories()
            }
        }
    }
    
    // MARK: - Subview für die Produktliste
    @ViewBuilder
    private func productListView(for subCategory: DisplayableSubCategory) -> some View {
        // ... (Dein Code für Ladezustände etc. ist hier gut) ...
        List {
            ForEach(viewModel.products) { product in
                // Dieser NavigationLink übergibt einfach den `product`-Wert.
                // Die CategoryListView fängt diesen Wert mit ihrem .navigationDestination ab.
                NavigationLink(value: product) {
                    ProductCardView(product: product) // Deine Produktkarten-Ansicht
                }
                .onAppear {
                    Task {
                        await viewModel.loadMoreProductsIfNeeded(currentItem: product)
                    }
                }
            }
            // ...
        }
        .listStyle(.plain)
        .navigationTitle(subCategory.label)
        // Dein Custom-Back-Button ist eine exzellente UI-Entscheidung und bleibt unverändert.
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    selectedSubCategory = nil
                    viewModel.products = []
                }) {
                    Image(systemName: "chevron.backward")
                    Text(viewModel.mainCategoryAppItem.label)
                }
                .tint(.blue) // Beispiel-Farbe
            }
        }
    }
}
