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

            // Die Logik wird durch `selectedSubCategory` gesteuert. Das ist gut.
            if let subCategory = selectedSubCategory {
                // Wir übergeben die Unterkategorie an die Produktliste-View
                productListView(for: subCategory)
            } else {
                subCategorySelectionView
            }
        }
        .navigationBarBackButtonHidden(true)
        // Der .task wird nur einmal ausgeführt, wenn SubCategoryListView erscheint
        .task {
            if viewModel.displayableSubCategories.isEmpty {
                await viewModel.loadSubCategories()
            }
        }
    }

    // MARK: - Subview für die Unterkategorie-Auswahl
    private var subCategorySelectionView: some View {
        // Die View wird in einer @ViewBuilder-Property gekapselt, um die body-Property zu entlasten
        Group {
            if viewModel.isLoadingSubcategories {
                loadingView(text: "Lade Unterkategorien...")
            } else if let errorMessage = viewModel.subcategoryErrorMessage {
                errorView(message: errorMessage)
            } else if viewModel.displayableSubCategories.isEmpty {
                emptyView(text: "Keine Unterkategorien gefunden.")
            } else {
                List(viewModel.displayableSubCategories) { subCat in
                    Button(action: {
                        // Der Wechsel der Ansicht erfolgt hier.
                        selectedSubCategory = subCat
                    }) {
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
            if viewModel.isLoadingProducts && viewModel.products.isEmpty {
                loadingView(text: "Lade Produkte...")
            } else if let errorMessage = viewModel.productErrorMessage {
                 errorView(message: errorMessage)
            } else if viewModel.products.isEmpty {
                 emptyView(text: "Keine Produkte in dieser Kategorie gefunden.")
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        NavigationLink(value: product) {
                            ProductCardView(product: product)
                                .task {
                                    // Wir laden mehr, wenn das letzte Element erscheint
                                    if viewModel.isLastProduct(product) {
                                        await viewModel.loadProducts(initialLoad: false)
                                    }
                                }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    if viewModel.isLoadingMoreProducts {
                        HStack { Spacer(); ProgressView().tint(AppColors.primary); Spacer() }
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .toolbar { productListToolbar(subCategory: subCategory) }
        // Der Lade-Task wird nur EINMAL ausgeführt, wenn diese Ansicht erscheint.
        .task(id: subCategory.id) { // id sorgt dafür, dass der Task bei Kategoriewechsel neu startet
             await viewModel.loadProducts(for: subCategory, initialLoad: true)
        }
    }
    
    // MARK: - Toolbar & Helper Views
    
    private var categorySelectionToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Shop")
                    }
                }
                .tint(AppColors.textLink)
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.mainCategoryAppItem.label)
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
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
            Text(text).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted)
        }
    }
    
    private func errorView(message: String) -> some View {
        Text(message).foregroundColor(AppColors.error).multilineTextAlignment(.center).padding()
    }

    private func emptyView(text: String) -> some View {
        Text(text).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted)
    }
}
