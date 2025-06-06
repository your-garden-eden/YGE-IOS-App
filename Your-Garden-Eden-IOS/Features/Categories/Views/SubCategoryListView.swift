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
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()

            Group {
                if let subCategory = selectedSubCategory {
                    productListView(for: subCategory)
                } else {
                    subCategorySelectionView
                }
            }
        }
    }

    // MARK: - Subview für die Unterkategorie-Auswahl
    private var subCategorySelectionView: some View {
        Group {
            // KORREKTUR: Hier wurde der Name der Eigenschaft korrigiert.
            if viewModel.isLoadingSubcategories {
                VStack(spacing: 12) {
                    ProgressView().tint(AppColors.primary)
                    Text("Lade Unterkategorien...")
                        .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
                        .foregroundColor(AppColors.textMuted)
                }
            } else if viewModel.displayableSubCategories.isEmpty {
                Text("Keine Unterkategorien gefunden.")
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
                    .foregroundColor(AppColors.textMuted)
            } else {
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
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.mainCategoryAppItem.label)
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
            }
        }
        .task {
            if viewModel.displayableSubCategories.isEmpty && !viewModel.isLoadingSubcategories {
                await viewModel.loadSubCategories()
            }
        }
    }
    
    // MARK: - Subview für die Produktliste
    @ViewBuilder
    private func productListView(for subCategory: DisplayableSubCategory) -> some View {
        Group {
            // NEU: Vollständiges Handling für Lade-, Fehler- und Leer-Zustand der Produkte
            if viewModel.isLoadingProducts && viewModel.products.isEmpty {
                VStack(spacing: 12) {
                    ProgressView().tint(AppColors.primary)
                    Text("Lade Produkte...").font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted)
                }
            } else if let errorMessage = viewModel.productErrorMessage {
                 Text(errorMessage).foregroundColor(AppColors.error).multilineTextAlignment(.center).padding()
            } else if viewModel.products.isEmpty {
                 Text("Keine Produkte in dieser Kategorie gefunden.").font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted)
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        NavigationLink(value: product) {
                            ProductCardView(product: product)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .onAppear {
                            Task { await viewModel.loadMoreProductsIfNeeded(currentItem: product) }
                        }
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Der Reset wird allein durch das Setzen der State-Variable ausgelöst
                    selectedSubCategory = nil
                }) {
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
}
