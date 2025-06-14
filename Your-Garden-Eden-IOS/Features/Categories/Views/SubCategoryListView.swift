// Path: Your-Garden-Eden-IOS/Features/Categories/SubCategoryListView.swift

import SwiftUI

struct SubCategoryListView: View {
    @StateObject private var viewModel: SubCategoryListViewModel
    @Environment(\.dismiss) private var dismiss

    init(selectedMainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        _viewModel = StateObject(wrappedValue: SubCategoryListViewModel(
            mainCategoryAppItem: selectedMainCategoryAppItem,
            parentWooCommerceCategoryID: parentWooCommerceCategoryID
        ))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            
            if viewModel.isLoading {
                loadingView(text: "Lade Unterkategorien...")
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if viewModel.displayableSubCategories.isEmpty {
                // Wenn keine Unterkategorien da sind, zeige direkt die Produkte der Hauptkategorie an
                let tempCategory = WooCommerceCategory(
                    id: viewModel.parentWooCommerceCategoryID, name: viewModel.mainCategoryAppItem.label,
                    slug: viewModel.mainCategoryAppItem.mainCategorySlug, parent: 0, description: "",
                    display: "", image: nil, menuOrder: 0, count: 0
                )
                CategoryDetailView(category: tempCategory)
            } else {
                subCategorySelectionList
            }
        }
        .navigationTitle(viewModel.mainCategoryAppItem.label)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.displayableSubCategories.isEmpty {
                await viewModel.loadSubCategories()
            }
        }
    }

    private var subCategorySelectionList: some View {
        List {
            ForEach(viewModel.displayableSubCategories) { subCat in
                NavigationLink(value: subCat) {
                    SubCategoryRow(subCategory: subCat)
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: AppStyles.Spacing.xSmall, leading: 0, bottom: AppStyles.Spacing.xSmall, trailing: 0))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal)
    }
    
    private func loadingView(text: String) -> some View {
        VStack(spacing: 12) { ProgressView().tint(AppColors.primary); Text(text).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted) }
    }
    
    private func errorView(message: String) -> some View {
        Text(message).foregroundColor(AppColors.error).multilineTextAlignment(.center).padding()
    }
}
