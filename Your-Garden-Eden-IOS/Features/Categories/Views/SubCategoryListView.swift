// Dateiname: Features/Categories/Views/SubCategoryListView.swift
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
        .toolbar { categorySelectionToolbar }
        .task {
            if viewModel.displayableSubCategories.isEmpty {
                await viewModel.loadSubCategories()
            }
        }
    }

    private var subCategorySelectionList: some View {
        List(viewModel.displayableSubCategories) { subCat in
            NavigationLink(value: subCat) {
                SubCategoryRow(subCategory: subCat)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.vertical, AppStyles.Spacing.xxSmall)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal)
    }
    
    private var categorySelectionToolbar: some ToolbarContent {
        Group { ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { dismiss() }) { HStack { Image(systemName: "chevron.backward"); Text("Shop") } }.tint(AppColors.textLink)
        }}
    }
    
    private func loadingView(text: String) -> some View {
        VStack(spacing: 12) { ProgressView().tint(AppColors.primary); Text(text).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted) }
    }
    
    private func errorView(message: String) -> some View {
        Text(message).foregroundColor(AppColors.error).multilineTextAlignment(.center).padding()
    }
    
    struct SubCategoryRow: View {
        let subCategory: DisplayableSubCategory
        var body: some View {
            HStack {
                Text(subCategory.label).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold)).foregroundColor(AppColors.textHeadings)
                Spacer()
                Text("\(subCategory.count)").font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted)
                Image(systemName: "chevron.right").foregroundColor(AppColors.textMuted.opacity(0.7))
            }
            .padding().background(AppColors.backgroundComponent).cornerRadius(AppStyles.BorderRadius.medium).appShadow(AppStyles.Shadows.small)
        }
    }
}
