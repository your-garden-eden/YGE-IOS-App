// Features/Categories/Views/CategoryListView.swift

import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()

    var body: some View {
        // DER NavigationStack WURDE ENTFERNT
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
        // DIE .navigationDestination Modifier WURDEN ENTFERNT
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
    
    private var categoryList: some View {
        List {
            ForEach(viewModel.categories) { wooCategory in
                if let navItem = AppNavigationData.findItem(forMainCategorySlug: wooCategory.slug) {
                    NavigationLink(value: wooCategory) {
                        ProductCategoryRow(
                            label: navItem.label,
                            imageUrl: wooCategory.image?.src.asURL(),
                            localImageFilename: navItem.imageFilename
                        )
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
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
