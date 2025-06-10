import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @EnvironmentObject var wishlistState: WishlistState
    @State private var quantity: Int = 1
    
    // NEU: Zustände für den "In den Warenkorb"-Button bei einfachen Produkten
    @State private var isAddingToCart = false
    @State private var addToCartError: String?

    private let productSlug: String

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        self.productSlug = productSlug
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(
            productSlug: productSlug,
            initialProductData: initialProductData
        ))
    }

    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            List {
                if viewModel.isLoading && viewModel.product == nil {
                    ProgressView().frame(maxWidth: .infinity, alignment: .center).listRowBackground(Color.clear)
                } else if let product = viewModel.product {
                    productGalleryView(allImages: product.images).listRowInsets(EdgeInsets()).listRowSeparator(.hidden).listRowBackground(AppColors.backgroundComponent)
                    productDetailsSection(product: product).listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)).listRowSeparator(.hidden).listRowBackground(AppColors.backgroundComponent)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).padding().listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColors.backgroundPage)
        }
        .navigationTitle(viewModel.product?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadDetails() }
    }

    // MARK: - Subviews

    private func productDetailsSection(product: WooCommerceProduct) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            productHeaderView(product: product)
            productPriceView()
            if let shortDescription = viewModel.formattedShortDescription, !shortDescription.characters.isEmpty {
                Text(shortDescription).font(.body).foregroundColor(AppColors.textBase)
            }
            actionButtonSection(product: product)
            
            if !viewModel.displayRelatedProducts.isEmpty {
                Divider()
                RelatedProductsView(products: viewModel.displayRelatedProducts)
            }
        }
    }

    @ViewBuilder
    private func productGalleryView(allImages: [WooCommerceImage]) -> some View {
        // ... (Dieser Teil bleibt unverändert) ...
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: viewModel.selectedImage?.src ?? "")) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFit()
                case .failure: Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted).frame(maxWidth: .infinity, minHeight: 300)
                case .empty: ProgressView().tint(AppColors.primary).frame(maxWidth: .infinity, minHeight: 300)
                @unknown default: EmptyView()
                }
            }.id(viewModel.selectedImage?.id ?? 0).frame(minHeight: 300)
            if allImages.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(allImages) { image in
                            Button(action: { viewModel.selectImage(image) }) {
                                AsyncImage(url: URL(string: image.src)) { phase in
                                    if let img = phase.image { img.resizable().scaledToFill() } else { Rectangle().fill(Color.gray.opacity(0.1)) }
                                }.frame(width: 60, height: 60).clipShape(RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)).overlay(RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).stroke(viewModel.selectedImage?.id == image.id ? AppColors.primary : Color.clear, lineWidth: 2))
                            }
                        }
                    }.padding(.horizontal)
                }
            }
        }.padding(.vertical)
    }

    private func productHeaderView(product: WooCommerceProduct) -> some View {
        // ... (Dieser Teil bleibt unverändert) ...
        HStack(alignment: .top) {
            Text(product.name).font(.largeTitle.weight(.bold)).foregroundColor(AppColors.textHeadings)
            Spacer()
            Button(action: { wishlistState.toggleWishlistStatus(for: product.id) }) {
                Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? AppColors.wishlistIcon : AppColors.textMuted)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }
    
    private func productPriceView() -> some View {
        // ... (Dieser Teil bleibt unverändert) ...
        Text(viewModel.displayPrice).font(.title2.weight(.bold)).foregroundColor(AppColors.price)
    }

    @ViewBuilder
    private func actionButtonSection(product: WooCommerceProduct) -> some View {
        VStack(spacing: 20) {
            // Für variable Produkte (unverändert)
            if product.type == .variable {
                NavigationLink(destination: ProductOptionsView(product: product, variations: viewModel.variations)) {
                    Text("Optionen wählen").font(.headline.weight(.bold)).foregroundColor(AppColors.textOnPrimary).frame(maxWidth: .infinity).padding().background(AppColors.primary).cornerRadius(AppStyles.BorderRadius.large)
                }.disabled(viewModel.variations.isEmpty && viewModel.isLoading)
            
            // KORREKTUR: Für einfache Produkte
            } else {
                if product.soldIndividually == false {
                    Stepper("Menge: \(quantity)", value: $quantity, in: 1...10).font(.headline.weight(.semibold))
                }
                
                Button(action: {
                    // Verwende asynchrone Logik
                    Task {
                        isAddingToCart = true
                        addToCartError = nil
                        do {
                            // Rufe den KORREKTEN Manager auf
                            try await CartAPIManager.shared.addItem(productId: product.id, quantity: quantity)
                            // Optional: Zeige eine Erfolgsmeldung (z.B. Banner)
                            isAddingToCart = false
                        } catch {
                            addToCartError = "Produkt konnte nicht hinzugefügt werden."
                            isAddingToCart = false
                        }
                    }
                }) {
                    if isAddingToCart {
                        ProgressView().tint(AppColors.textOnPrimary)
                            .frame(maxWidth: .infinity).padding()
                    } else {
                        Text("In den Warenkorb").font(.headline.weight(.bold))
                            .foregroundColor(AppColors.textOnPrimary)
                            .frame(maxWidth: .infinity).padding()
                    }
                }
                .background(AppColors.primary)
                .cornerRadius(AppStyles.BorderRadius.large)
                .disabled(product.stockStatus != .instock || isAddingToCart)
                
                if let error = addToCartError {
                    Text(error).font(.caption).foregroundColor(AppColors.error)
                }
            }
        }.padding(.top)
    }
}
