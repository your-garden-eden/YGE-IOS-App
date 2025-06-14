// Path: Your-Garden-Eden-IOS/Features/Products/ProductDetailView.swift

import SwiftUI

struct ProductDetailView: View {
    let product: WooCommerceProduct
    
    @StateObject private var viewModel = ProductDetailViewModel()
    @EnvironmentObject var wishlistState: WishlistState
    @EnvironmentObject var cartManager: CartAPIManager
    
    @State private var showAddedToCartConfirmation = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppStyles.Spacing.large) {
                    productGallery
                    productHeader
                    
                    if product.type == .variable && viewModel.isLoadingVariations {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 50)
                    } else if let error = viewModel.variationError {
                        ErrorStateView(message: error)
                    }
                    
                    Divider()
                    descriptionSection
                    crossSellSection
                    
                    Spacer(minLength: 150) // Placeholder for bottom bar
                }
            }
            .safeAreaInset(edge: .bottom) {
                 bottomActionSection
            }
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle(product.name.strippingHTML())
        .navigationBarTitleDisplayMode(.inline)
        .task(id: product.id) {
            await viewModel.loadData(for: product)
        }
        .overlay(confirmationBanner)
        .onChange(of: cartManager.state.errorMessage) { _, newValue in
             if newValue != nil {
                 DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                     // Error message will be cleared by the manager itself
                 }
             }
        }
        .onChange(of: cartManager.state.items) { _, _ in
             if cartManager.state.errorMessage == nil {
                 withAnimation { showAddedToCartConfirmation = true }
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                     withAnimation { showAddedToCartConfirmation = false }
                 }
             }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder private var productGallery: some View {
        AsyncImage(url: product.images.first?.src.asURL()) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFit()
            case .failure: Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted)
            default: ProgressView().tint(AppColors.primary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(AppColors.backgroundLightGray)
    }
    
    @ViewBuilder private var productHeader: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            HStack(alignment: .top) {
                Text(product.name.strippingHTML())
                    .font(AppFonts.montserrat(size: AppFonts.Size.h4, weight: .bold))
                Spacer()
                Button(action: { wishlistState.toggleWishlistStatus(for: product) }) {
                    Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                        .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? .red : .secondary)
                }
                .font(.title)
                .animation(.spring(), value: wishlistState.isProductInWishlist(productId: product.id))
            }
            
            let priceInfo = PriceFormatter.formatPriceString(from: product.priceHtml, fallbackPrice: product.price, currencySymbol: "€")
            HStack(alignment: .bottom, spacing: AppStyles.Spacing.small) {
                Text(priceInfo.display)
                    .font(AppFonts.roboto(size: AppFonts.Size.h5, weight: .bold))
                    .foregroundColor(AppColors.price)
                if let strikethrough = priceInfo.strikethrough {
                    Text(strikethrough)
                        .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular))
                        .strikethrough(true, color: AppColors.textMuted)
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            Text("Beschreibung").font(AppFonts.montserrat(size: AppFonts.Size.h6, weight: .semibold))
            ExpandableTextView(text: product.description, lineLimit: 5)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var crossSellSection: some View {
        if viewModel.isLoadingCrossSells || !viewModel.crossSellProducts.isEmpty {
            VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                Divider().padding(.horizontal)
                Text("Kunden kauften auch")
                    .font(AppFonts.montserrat(size: AppFonts.Size.h6, weight: .semibold))
                    .padding(.horizontal)

                if viewModel.isLoadingCrossSells {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    RelatedProductsView(products: viewModel.crossSellProducts.map { IdentifiableDisplayProduct(product: $0) })
                }
            }
        }
    }
    
    @ViewBuilder private var bottomActionSection: some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            if product.type == .simple {
                if !product.soldIndividually {
                    QuantitySelectorView(quantity: $viewModel.quantity)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task { await viewModel.addSimpleProductToCart(productID: product.id) }
                }) {
                    HStack {
                        if cartManager.state.isLoading { ProgressView().tint(.white) }
                        else { Text("In den Warenkorb") }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(cartManager.state.isLoading || !product.purchasable)
            
            } else if product.type == .variable {
                let isNavigationDisabled = (viewModel.variations.isEmpty && viewModel.variationError == nil) || !product.purchasable
                
                NavigationLink(value: ProductVariationData(product: product, variations: viewModel.variations)) {
                    Text("Optionen auswählen")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isNavigationDisabled)
            }
        }
        .padding()
        .background(.regularMaterial)
    }
    
    @ViewBuilder private var confirmationBanner: some View {
        VStack {
            if showAddedToCartConfirmation {
                SuccessBanner(message: "Zum Warenkorb hinzugefügt")
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            if let errorMessage = cartManager.state.errorMessage {
                ErrorBanner(message: errorMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top).padding(.top)
    }
}

// Banner Helper Views
struct SuccessBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.success)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
    }
}

struct ErrorBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.error)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
    }
}

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published private(set) var variations: [WooCommerceProductVariation] = []
    @Published private(set) var isLoadingVariations: Bool = false
    @Published private(set) var variationError: String?
    
    @Published private(set) var crossSellProducts: [WooCommerceProduct] = []
    @Published private(set) var isLoadingCrossSells: Bool = false
    
    @Published var quantity: Int = 1
    
    private let api = WooCommerceAPIManager.shared
    private let cartManager = CartAPIManager.shared

    func loadData(for product: WooCommerceProduct) async {
        await withTaskGroup(of: Void.self) { group in
            if product.type == .variable {
                group.addTask { await self.loadVariations(for: product) }
            }
            if !product.crossSellIds.isEmpty {
                group.addTask { await self.loadCrossSells(for: product) }
            }
        }
    }
    
    private func loadVariations(for product: WooCommerceProduct) async {
        guard variations.isEmpty, !isLoadingVariations else { return }
        self.isLoadingVariations = true
        self.variationError = nil
        do {
            self.variations = try await api.fetchProductVariations(productId: product.id)
        } catch {
            self.variationError = "Die Produktvarianten konnten nicht geladen werden."
        }
        self.isLoadingVariations = false
    }
    
    private func loadCrossSells(for product: WooCommerceProduct) async {
        guard !isLoadingCrossSells else { return }
        self.isLoadingCrossSells = true
        do {
            let response = try await api.fetchProducts(include: product.crossSellIds)
            self.crossSellProducts = response.products
        } catch {
            print("🔴 ProductDetailVM: Failed to load cross-sells: \(error.localizedDescription)")
            self.crossSellProducts = []
        }
        self.isLoadingCrossSells = false
    }

    func addSimpleProductToCart(productID: Int) async {
        await cartManager.addItem(productId: productID, quantity: self.quantity)
    }
}
