// Dateiname: Features/Categories/Views/CategoryDetailView.swift

import SwiftUI

struct CategoryDetailView: View {
    @StateObject private var viewModel: ProductListViewModel
    private let categoryName: String

    init(category: WooCommerceCategory) {
        _viewModel = StateObject(wrappedValue: ProductListViewModel(categoryId: category.id))
        self.categoryName = category.name
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(AppColors.error).padding()
            } else if viewModel.products.isEmpty {
                 emptyView
            } else {
                productGrid
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadProducts(initialLoad: true)
        }
    }
    
    private var productGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.products) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
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
            
            if viewModel.isLoading {
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
