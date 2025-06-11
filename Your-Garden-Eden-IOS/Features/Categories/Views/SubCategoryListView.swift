import SwiftUI

struct SubCategoryListView: View {
    @StateObject private var viewModel: SubCategoryViewModel
    @State private var selectedSubCategory: DisplayableSubCategory? = nil
    
    @Environment(\.dismiss) private var dismiss

    init(selectedMainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        _viewModel = StateObject(wrappedValue: SubCategoryViewModel(
            mainCategoryAppItem: selectedMainCategoryAppItem,
            parentWooCommerceCategoryID: parentWooCommerceCategoryID
        ))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            if let subCategory = selectedSubCategory {
                productListView(for: subCategory)
            } else {
                subCategorySelectionView
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            if viewModel.displayableSubCategories.isEmpty {
                await viewModel.loadSubCategories()
            }
        }
    }

    // MARK: - Subview für die Unterkategorie-Auswahl
    private var subCategorySelectionView: some View {
        Group {
            if viewModel.isLoadingSubcategories { loadingView(text: "Lade Unterkategorien...") }
            else if let errorMessage = viewModel.subcategoryErrorMessage { errorView(message: errorMessage) }
            else if viewModel.displayableSubCategories.isEmpty { emptyView(text: "Keine Unterkategorien gefunden.") }
            else {
                List(viewModel.displayableSubCategories) { subCat in
                    Button(action: { selectedSubCategory = subCat }) {
                        SubCategoryRow(subCategory: subCat)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .toolbar { categorySelectionToolbar }
    }
    
    // MARK: - Subview für die Produktliste
    private func productListView(for subCategory: DisplayableSubCategory) -> some View {
        Group {
            if viewModel.isLoadingProducts && viewModel.products.isEmpty { loadingView(text: "Lade Produkte...") }
            else if let errorMessage = viewModel.productErrorMessage { errorView(message: errorMessage) }
            else if viewModel.products.isEmpty { emptyView(text: "Keine Produkte in dieser Kategorie gefunden.") }
            else {
                List {
                    ForEach(viewModel.products) { product in
                        NavigationLink(value: product) {
                            ProductCardView(product: product)
                                .task {
                                    if viewModel.isLastProduct(product) { await viewModel.loadProducts(initialLoad: false) }
                                }
                        }
                        .listRowBackground(Color.clear).listRowSeparator(.hidden)
                    }
                    if viewModel.isLoadingMoreProducts {
                        HStack { Spacer(); ProgressView().tint(AppColors.primary); Spacer() }.listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain).scrollContentBackground(.hidden)
            }
        }
        .toolbar { productListToolbar(subCategory: subCategory) }
        .task(id: subCategory.id) { await viewModel.loadProducts(for: subCategory, initialLoad: true) }
    }
    
    // MARK: - Toolbar & Helper Views
    
    private var categorySelectionToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text(viewModel.mainCategoryAppItem.label)
                    }
                }
                .tint(AppColors.textLink)
            }
        }
    }
    
    private func productListToolbar(subCategory: DisplayableSubCategory) -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { selectedSubCategory = nil }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text(viewModel.mainCategoryAppItem.label)
                    }
                }
                .tint(AppColors.textLink)
            }
            ToolbarItem(placement: .principal) {
                Text(subCategory.label)
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
            }
        }
    }
    
    private func loadingView(text: String) -> some View {
        VStack(spacing: 12) {
            ProgressView().tint(AppColors.primary)
            // KORREKTUR: Verwende die korrekte Font-Größe aus deinem Design-System.
            Text(text).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted)
        }
    }
    
    private func errorView(message: String) -> some View {
        Text(message).foregroundColor(.red).multilineTextAlignment(.center).padding()
    }

    private func emptyView(text: String) -> some View {
        // KORREKTUR: Verwende die korrekte Font-Größe aus deinem Design-System.
        Text(text).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted)
    }
}
