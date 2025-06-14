// Path: Your-Garden-Eden-IOS/Features/Categories/CategoryDetailView.swift

import SwiftUI

struct CategoryDetailView: View {
    @StateObject private var viewModel: ProductListViewModel
    private let categoryName: String

    init(category: WooCommerceCategory) {
        _viewModel = StateObject(wrappedValue: ProductListViewModel(categoryId: category.id))
        self.categoryName = category.name.strippingHTML()
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView().tint(AppColors.primary)
            } else if let errorMessage = viewModel.errorMessage {
                // KORREKTUR: Direkter Aufruf der neuen, wiederverwendbaren View
                ErrorStateView(message: errorMessage)
            } else if viewModel.products.isEmpty {
                 emptyView
            } else {
                productGrid
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Lädt die Produkte nur, wenn die Liste leer ist.
            if viewModel.products.isEmpty {
                await viewModel.loadProducts(initialLoad: true)
            }
        }
    }
    
    private var productGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: AppStyles.Spacing.medium), GridItem(.flexible(), spacing: AppStyles.Spacing.medium)], spacing: AppStyles.Spacing.medium) {
                ForEach(viewModel.products) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .task {
                        if viewModel.isLastProduct(product) && viewModel.canLoadMore {
                            await viewModel.loadProducts()
                        }
                    }
                }
            }
            .padding()
            
            if viewModel.isLoading && !viewModel.products.isEmpty {
                ProgressView().padding()
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "bag.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primary.opacity(0.5))
            Text("Keine Produkte")
                .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold))
                .foregroundColor(AppColors.textHeadings)
            Text("In dieser Kategorie wurden leider keine Produkte gefunden.")
                .font(AppFonts.roboto(size: AppFonts.Size.body))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
