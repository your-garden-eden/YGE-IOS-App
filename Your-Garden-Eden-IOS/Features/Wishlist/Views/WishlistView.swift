// Features/Wishlist/Views/WishlistView.swift
import SwiftUI
import Combine

// MARK: - Zustands-Enum für die WishlistView
fileprivate enum WishlistViewLoadingState {
    case initializingViewModel
    case loading
    case error(String)
    case empty // Wunschliste ist leer (Nutzer gilt als aktiv/eingeloggt)
    case productsCouldNotBeLoaded // Fehler beim Laden der Produktdetails für bekannte IDs
    case loaded([WooCommerceProduct])
}

@MainActor
fileprivate class WishlistViewModelHolder: ObservableObject {
    @Published var viewModel: WishlistViewModel?
}

struct WishlistView: View {
    @EnvironmentObject var wishlistState: WishlistState
    @EnvironmentObject var authManager: FirebaseAuthManager
    @EnvironmentObject var cartAPIManager: CartAPIManager
    @StateObject private var viewModelHolder = WishlistViewModelHolder()

    private var currentLoadingState: WishlistViewLoadingState {
        guard let vm = viewModelHolder.viewModel else { return .initializingViewModel }
        if let errorMessage = vm.errorMessage, !errorMessage.isEmpty { return .error(errorMessage) }
        if !vm.wishlistProducts.isEmpty { return .loaded(vm.wishlistProducts) }
        if vm.isLoading { return .loading }
        if wishlistState.isLoading && wishlistState.wishlistProductIds.isEmpty { return .loading }
        if wishlistState.wishlistProductIds.isEmpty && !wishlistState.isLoading { return .empty }
        // Die folgende Zeile wurde in der Logik der currentLoadingState leicht angepasst,
        // um sicherzustellen, dass !wishlistState.isLoading auch hier gilt,
        // da vm.isLoading bereits als false angenommen wird an diesem Punkt.
        if !wishlistState.wishlistProductIds.isEmpty && vm.wishlistProducts.isEmpty && !vm.isLoading && !wishlistState.isLoading {
            return .productsCouldNotBeLoaded
        }
        return .loading // Fallback
    }
    
    var body: some View {
        let _ = print("WishlistView body RE-EVALUATING. CurrentLoadingState: \(currentLoadingState), ViewModel products count: \(viewModelHolder.viewModel?.wishlistProducts.count ?? -1), ViewModel isLoading: \(viewModelHolder.viewModel?.isLoading ?? false), WishlistState IDs count: \(wishlistState.wishlistProductIds.count), WishlistState isLoading: \(wishlistState.isLoading)")
        NavigationStack {
            switch currentLoadingState {
            case .initializingViewModel: initialProgressView()
            case .loading: loadingView(message: "Lade Wunschliste...")
            case .error(let message): errorStateView(errorMessage: message, viewModel: viewModelHolder.viewModel!)
            case .empty: emptyStateView(productsCouldNotBeLoaded: false, viewModel: viewModelHolder.viewModel!)
            case .productsCouldNotBeLoaded: emptyStateView(productsCouldNotBeLoaded: true, viewModel: viewModelHolder.viewModel!)
            case .loaded(let products): productList(products: products, viewModel: viewModelHolder.viewModel!)
            }
        }
        .task {
            if viewModelHolder.viewModel == nil {
                print("WishlistView (.task): Initializing WishlistViewModel.")
                viewModelHolder.viewModel = WishlistViewModel(wishlistState: wishlistState)
            } else {
                print("WishlistView (.task): ViewModel already initialized.")
            }
        }
        .navigationTitle("Meine Wunschliste")
        .toolbar {
            if case .loaded(let products) = currentLoadingState, !products.isEmpty { EditButton() }
        }
        .background(AppColors.backgroundPage.ignoresSafeArea()) // Globale Hintergrundfarbe für die gesamte View
    }

    private func emptyStateImageName(productsCouldNotBeLoaded: Bool) -> String {
        if productsCouldNotBeLoaded {
            if #available(iOS 16.0, *) { return "exclamationmark.heart.fill" }
            else { return "exclamationmark.triangle.fill" }
        } else { return "heart.fill" }
    }

    @ViewBuilder
    private func initialProgressView() -> some View {
        ProgressView("Initialisiere...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.backgroundPage.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func loadingView(message: String) -> some View {
        ProgressView(message)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.backgroundPage.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func emptyStateView(productsCouldNotBeLoaded: Bool, viewModel: WishlistViewModel) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            Image(systemName: emptyStateImageName(productsCouldNotBeLoaded: productsCouldNotBeLoaded))
                .font(.system(size: 50))
                .foregroundColor(productsCouldNotBeLoaded ? AppColors.error : AppColors.textMuted)
            Text(productsCouldNotBeLoaded ? "Fehler beim Produktabruf" : "Deine Wunschliste ist leer")
                .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            Text(productsCouldNotBeLoaded ?
                 "Die Details zu den Produkten auf deiner Wunschliste konnten nicht geladen werden. Bitte versuche es erneut."
                 : "Füge Produkte hinzu, die dir gefallen, um sie hier später wiederzufinden.")
                .font(AppFonts.roboto(size: AppFonts.Size.body))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            if productsCouldNotBeLoaded {
                Button("Erneut versuchen") { viewModel.retryLoadProducts() }
                .buttonStyle(.borderedProminent).tint(AppColors.primary).padding(.top)
            }
        }
        .padding(AppStyles.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Hintergrund für emptyStateView, passend zur gesamten View
        .background(AppColors.backgroundPage.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func errorStateView(errorMessage: String, viewModel: WishlistViewModel) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40)).foregroundColor(AppColors.error)
            Text("Fehler").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            Text(errorMessage).font(AppFonts.roboto(size: AppFonts.Size.body))
                .foregroundColor(AppColors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
            Button("Erneut versuchen") { viewModel.retryLoadProducts() }
            .buttonStyle(.borderedProminent).tint(AppColors.primary).padding(.top)
        }
        .padding(AppStyles.Spacing.large).frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPage.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func productList(products: [WooCommerceProduct], viewModel: WishlistViewModel) -> some View {
        let _ = print("WishlistView - productList VIEW Rendering with \(products.count) products.")
        List {
            ForEach(products) { product in
                let _ = print("WishlistView - productList ForEach: Rendering product ID \(product.id), Name: \(product.name)")
                NavigationLink(value: product) { WishlistRowView(product: product) }
            }
            .onDelete { offsets in deleteItems(offsets: offsets, products: products, viewModel: viewModel) }
        }
        .listStyle(.plain)
        // Hintergrund für die List selbst, .scrollContentBackground(.hidden) entfernt den Standard-Systemhintergrund der List
        .background(AppColors.backgroundPage)
        .scrollContentBackground(.hidden)
        .refreshable {
            print("WishlistView: Pull-to-refresh triggered.")
            viewModel.retryLoadProducts()
        }
        .navigationDestination(for: WooCommerceProduct.self) { product in
             ProductDetailView(productSlug: product.slug, initialProductData: product)
                 .environmentObject(wishlistState).environmentObject(cartAPIManager)
        }
    }

    private func deleteItems(offsets: IndexSet, products: [WooCommerceProduct], viewModel: WishlistViewModel) {
        let productsToDelete = offsets.map { products[$0] }
        for product in productsToDelete { wishlistState.removeProductFromWishlist(productId: product.id) }
    }
}
