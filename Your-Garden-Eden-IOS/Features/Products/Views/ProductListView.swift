import SwiftUI

struct ProductListView: View {
    
    @StateObject private var viewModel: ProductListViewModel
    // FIX: Die View hat keinen eigenen Headline-Text mehr.
    private let navigationBarTitle: String

    init(category: WooCommerceCategory) {
        let displayName = Self.findLabelFor(category: category)
        self.navigationBarTitle = displayName
        // Der ViewModel wird ohne Headline initialisiert.
        _viewModel = StateObject(wrappedValue: ProductListViewModel(context: .categoryId(category.id)))
    }

    var body: some View {
        // FIX: Die äußere VStack wurde entfernt. Die View hat keine eigene Überschrift mehr.
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView().tint(AppColors.primary)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(message: errorMessage)
            } else if viewModel.products.isEmpty {
                emptyView
            } else {
                productGrid
            }
        }
        .task {
            await viewModel.loadProducts()
        }
        // FIX: Der Titel wird nur noch in der Navigationsleiste oben angezeigt.
        .navigationTitle(navigationBarTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var productGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: AppStyles.Spacing.medium), GridItem(.flexible(), spacing: AppStyles.Spacing.medium)], spacing: AppStyles.Spacing.medium) {
                ForEach(viewModel.products) { product in
                    NavigationLink(value: product) {
                        ProductCardView(product: product)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if product.id == viewModel.products.dropLast(5).last?.id && viewModel.canLoadMore {
                            Task { await viewModel.loadMoreProducts() }
                        }
                    }
                }
            }
            .padding()
            
            if viewModel.isLoadingMore {
                ProgressView().padding()
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "bag.fill").font(.system(size: 60)).foregroundColor(AppColors.primary.opacity(0.5))
            Text("Keine Produkte").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold)).foregroundColor(AppColors.textHeadings)
            Text("In dieser Kategorie wurden leider keine Produkte gefunden.").font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center)
        }.padding()
    }
    
    private static func findLabelFor(category: WooCommerceCategory) -> String {
        if let mainItem = AppNavigationData.items.first(where: { $0.mainCategorySlug == category.slug }) {
            return mainItem.label
        }
        for item in AppNavigationData.items {
            if let subItems = item.subItems, let subItem = subItems.first(where: { $0.linkSlug == category.slug }) {
                return subItem.label
            }
        }
        return category.name.strippingHTML()
    }
}
