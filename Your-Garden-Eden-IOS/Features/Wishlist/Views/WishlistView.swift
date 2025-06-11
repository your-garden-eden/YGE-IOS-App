import SwiftUI

fileprivate enum WishlistViewLoadingState: Equatable {
    case initializing, loading, empty, productsCouldNotBeLoaded, error(String), loaded([WooCommerceProduct])
    static func == (lhs: WishlistViewLoadingState, rhs: WishlistViewLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing): return true
        case (.loading, .loading): return true
        case (.empty, .empty): return true
        case (.productsCouldNotBeLoaded, .productsCouldNotBeLoaded): return true
        case (.error(let a), .error(let b)): return a == b
        case (.loaded(let a), .loaded(let b)): return a == b
        default: return false
        }
    }
}

@MainActor
fileprivate class WishlistViewModelHolder: ObservableObject {
    @Published var viewModel: WishlistViewModel?
}

struct WishlistView: View {
    @EnvironmentObject var wishlistState: WishlistState
    @StateObject private var viewModelHolder = WishlistViewModelHolder()

    private var currentLoadingState: WishlistViewLoadingState {
        guard let vm = viewModelHolder.viewModel else { return .initializing }
        if let errorMessage = vm.errorMessage { return .error(errorMessage) }
        if vm.isLoading && vm.wishlistProducts.isEmpty { return .loading }
        if vm.wishlistProducts.isEmpty {
            return wishlistState.wishlistProductIds.isEmpty ? .empty : .productsCouldNotBeLoaded
        }
        return .loaded(vm.wishlistProducts)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch currentLoadingState {
                case .initializing: ProgressView().tint(AppColors.primary)
                case .loading: ProgressView("Lade Wunschliste...").tint(AppColors.primary)
                case .error(let message): errorStateView(errorMessage: message)
                case .empty: emptyStateView(productsCouldNotBeLoaded: false)
                case .productsCouldNotBeLoaded: emptyStateView(productsCouldNotBeLoaded: true)
                case .loaded(let products): productListView(products: products)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.backgroundPage.ignoresSafeArea())
            .navigationTitle("Meine Wunschliste")
            .toolbar {
                if case .loaded(let products) = currentLoadingState, !products.isEmpty { EditButton().tint(AppColors.primary) }
            }
        }
        .task {
            if viewModelHolder.viewModel == nil {
                viewModelHolder.viewModel = WishlistViewModel(wishlistState: wishlistState)
            }
        }
    }

    private func emptyStateImageName(productsCouldNotBeLoaded: Bool) -> String {
        return productsCouldNotBeLoaded ? "exclamationmark.triangle.fill" : "heart.fill"
    }

    @ViewBuilder
    private func emptyStateView(productsCouldNotBeLoaded: Bool) -> some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: emptyStateImageName(productsCouldNotBeLoaded: productsCouldNotBeLoaded))
                .font(.system(size: 50)).foregroundColor(productsCouldNotBeLoaded ? AppColors.error : AppColors.wishlistIcon.opacity(0.6))
            Text(productsCouldNotBeLoaded ? "Fehler beim Produktabruf" : "Deine Wunschliste ist leer")
                .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold)).foregroundColor(AppColors.textHeadings)
            Text(productsCouldNotBeLoaded ? "Die Details zu den Produkten konnten nicht geladen werden." : "Füge Produkte hinzu, um sie hier später wiederzufinden.")
                .font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
            if productsCouldNotBeLoaded {
                Button("Erneut versuchen") {
                    Task { await viewModelHolder.viewModel?.retryLoadProducts() }
                }.buttonStyle(.borderedProminent).tint(AppColors.primary).padding(.top)
            }
        }
        .padding(AppStyles.Spacing.large)
    }
    
    @ViewBuilder
    private func errorStateView(errorMessage: String) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 40)).foregroundColor(AppColors.error)
            Text("Fehler").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold))
            Text(errorMessage).font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
            Button("Erneut versuchen") {
                // KORREKTUR: Der Aufruf einer async-Funktion aus einer synchronen Button-Action benötigt einen Task.
                Task { await viewModelHolder.viewModel?.retryLoadProducts() }
            }.buttonStyle(.borderedProminent).tint(AppColors.primary).padding(.top)
        }
        .padding(AppStyles.Spacing.large)
    }
    
    @ViewBuilder
    private func productListView(products: [WooCommerceProduct]) -> some View {
        List {
            ForEach(products) { product in
                NavigationLink(value: product) { WishlistRowView(product: product) }
            }
            .onDelete { offsets in
                let productsToDelete = offsets.map { products[$0] }
                for product in productsToDelete { wishlistState.removeProductFromWishlist(productId: product.id) }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(AppColors.backgroundComponent)
        }
        .listStyle(.plain)
        .background(AppColors.backgroundPage)
        .scrollContentBackground(.hidden)
        // KORREKTUR: Die Warnung ist jetzt behoben, da die aufgerufene Funktion async ist.
        .refreshable { await viewModelHolder.viewModel?.fetchWishlistProducts() }
        .navigationDestination(for: WooCommerceProduct.self) { product in
             ProductDetailView(productSlug: product.slug, initialProductData: product)
        }
    }
}
