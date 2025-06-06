import SwiftUI
import Combine

fileprivate enum WishlistViewLoadingState {
    case initializingViewModel, loading, empty, productsCouldNotBeLoaded
    case error(String)
    case loaded([WooCommerceProduct])
}

@MainActor
fileprivate class WishlistViewModelHolder: ObservableObject {
    @Published var viewModel: WishlistViewModel?
}

struct WishlistView: View {
    @EnvironmentObject var wishlistState: WishlistState
    // ... andere EnvironmentObjects
    @StateObject private var viewModelHolder = WishlistViewModelHolder()

    private var currentLoadingState: WishlistViewLoadingState {
        guard let vm = viewModelHolder.viewModel else { return .initializingViewModel }
        if let errorMessage = vm.errorMessage { return .error(errorMessage) }
        if vm.isLoading { return .loading }
        if vm.wishlistProducts.isEmpty {
            return wishlistState.wishlistProductIds.isEmpty ? .empty : .productsCouldNotBeLoaded
        }
        return .loaded(vm.wishlistProducts)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch currentLoadingState {
                case .initializingViewModel: ProgressView("Initialisiere...")
                case .loading: ProgressView("Lade Wunschliste...")
                case .error(let message): errorStateView(errorMessage: message, viewModel: viewModelHolder.viewModel!)
                case .empty: emptyStateView(productsCouldNotBeLoaded: false, viewModel: viewModelHolder.viewModel!)
                case .productsCouldNotBeLoaded: emptyStateView(productsCouldNotBeLoaded: true, viewModel: viewModelHolder.viewModel!)
                case .loaded(let products): productList(products: products, viewModel: viewModelHolder.viewModel!)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.backgroundPage.ignoresSafeArea())
            .navigationTitle("Meine Wunschliste")
            .toolbar {
                if case .loaded(let products) = currentLoadingState, !products.isEmpty { EditButton() }
            }
        }
        .task {
            if viewModelHolder.viewModel == nil {
                viewModelHolder.viewModel = WishlistViewModel(wishlistState: wishlistState)
            }
        }
    }

    private func emptyStateImageName(productsCouldNotBeLoaded: Bool) -> String {
        // --- KORREKTUR ---
        // 'exclamationmark.heart.fill' existiert nicht. Wir verwenden ein
        // Standard-Fehlersymbol, das klar und immer verfügbar ist.
        return productsCouldNotBeLoaded ? "exclamationmark.triangle.fill" : "heart.fill"
    }

    @ViewBuilder
    private func emptyStateView(productsCouldNotBeLoaded: Bool, viewModel: WishlistViewModel) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            Image(systemName: emptyStateImageName(productsCouldNotBeLoaded: productsCouldNotBeLoaded))
                .font(.system(size: 50))
                .foregroundColor(productsCouldNotBeLoaded ? AppColors.error : AppColors.textMuted)
            Text(productsCouldNotBeLoaded ? "Fehler beim Produktabruf" : "Deine Wunschliste ist leer")
                .font(.headline.weight(.semibold))
                .foregroundColor(AppColors.textHeadings)
            Text(productsCouldNotBeLoaded ?
                 "Die Details zu den Produkten auf deiner Wunschliste konnten nicht geladen werden. Bitte versuche es erneut."
                 : "Füge Produkte hinzu, die dir gefallen, um sie hier später wiederzufinden.")
                .font(.subheadline)
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if productsCouldNotBeLoaded {
                Button("Erneut versuchen") { viewModel.retryLoadProducts() }
                    .buttonStyle(.borderedProminent).tint(AppColors.primary).padding(.top)
            }
        }
        .padding(AppStyles.Spacing.large)
    }
    
    @ViewBuilder
    private func errorStateView(errorMessage: String, viewModel: WishlistViewModel) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40)).foregroundColor(AppColors.error)
            Text("Fehler").font(.title2.weight(.semibold))
            Text(errorMessage).font(.body).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
            Button("Erneut versuchen") { viewModel.retryLoadProducts() }
                .buttonStyle(.borderedProminent).tint(AppColors.primary).padding(.top)
        }
        .padding(AppStyles.Spacing.large)
    }
    
    @ViewBuilder
    private func productList(products: [WooCommerceProduct], viewModel: WishlistViewModel) -> some View {
        List {
            ForEach(products) { product in
                NavigationLink(value: product) { WishlistRowView(product: product) }
            }
            .onDelete { offsets in
                let productsToDelete = offsets.map { products[$0] }
                for product in productsToDelete { wishlistState.removeProductFromWishlist(productId: product.id) }
            }
        }
        .listStyle(.plain)
        .background(AppColors.backgroundPage)
        .scrollContentBackground(.hidden)
        .refreshable { viewModel.retryLoadProducts() }
        .navigationDestination(for: WooCommerceProduct.self) { product in
             ProductDetailView(productSlug: product.slug, initialProductData: product)
        }
    }
}
