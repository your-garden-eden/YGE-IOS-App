import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    
    @ObservedObject private var cartManager = CartAPIManager.shared
    @EnvironmentObject var wishlistState: WishlistState
    
    @State private var quantity: Int = 1
    @State private var isAddingToCart = false
    @State private var addToCartError: String?

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(
            productSlug: productSlug,
            initialProductData: initialProductData
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let product = viewModel.product {
                    // WIEDERHERGESTELLT: Bildergalerie
                    productGalleryView(images: product.images)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        productHeaderView(product: product)
                        
                        // KORRIGIERT: Preisansicht mit der neuen, synchronen strippingHTML() Funktion
                        Text((product.priceHtml ?? product.price).strippingHTML())
                            .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold))
                            .foregroundColor(AppColors.price)
                        
                        // WIEDERHERGESTELLT: Beschreibung
                        Text(product.description.strippingHTML())
                            .font(AppFonts.roboto(size: AppFonts.Size.body))
                            .foregroundColor(AppColors.textMuted)
                        
                        Divider()
                        
                        actionSection(product: product)
                    }
                    .padding()
                    
                } else if viewModel.isLoading {
                    ProgressView().tint(AppColors.primary).padding(.top, 50)
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Fehler: \(errorMessage)").foregroundColor(AppColors.error).padding()
                }
            }
        }
        .navigationTitle(viewModel.product?.name.strippingHTML() ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDetails()
        }
    }

    @ViewBuilder
    private func productGalleryView(images: [WooCommerceImage]) -> some View {
        TabView {
            ForEach(images) { image in
                AsyncImage(url: image.src.asURL()) { phase in
                    switch phase {
                    case .success(let img): img.resizable().aspectRatio(contentMode: .fit)
                    case .failure: Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted)
                    default: ProgressView().tint(AppColors.primary)
                    }
                }
            }
        }
        .frame(height: 300).tabViewStyle(.page).background(AppColors.backgroundComponent)
    }
    
    @ViewBuilder
    private func productHeaderView(product: WooCommerceProduct) -> some View {
        HStack(alignment: .top) {
            Text(product.name.strippingHTML())
                .font(AppFonts.montserrat(size: AppFonts.Size.largeTitle, weight: .bold))
                .foregroundColor(AppColors.textHeadings)
            Spacer()
            Button(action: { wishlistState.toggleWishlistStatus(for: product.id) }) {
                Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                    .font(.title2).foregroundColor(AppColors.wishlistIcon)
            }
        }
    }
    
    @ViewBuilder
    private func actionSection(product: WooCommerceProduct) -> some View {
        VStack(spacing: 16) {
            if !product.soldIndividually {
                 Stepper("Menge: \(quantity)", value: $quantity, in: 1...10).font(AppFonts.roboto(size: AppFonts.Size.headline))
            }
            Button(action: {
                Task {
                    isAddingToCart = true; addToCartError = nil
                    do { try await cartManager.addItem(productId: product.id, quantity: quantity) }
                    catch { addToCartError = "Produkt konnte nicht hinzugefügt werden." }
                    isAddingToCart = false
                }
            }) {
                if isAddingToCart {
                    ProgressView().tint(AppColors.textOnPrimary).frame(maxWidth: .infinity, minHeight: 24)
                } else {
                    Text("In den Warenkorb").font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                        .foregroundColor(AppColors.textOnPrimary).frame(maxWidth: .infinity)
                }
            }
            .disabled(isAddingToCart || product.stockStatus != .instock)
            .padding().background(product.stockStatus == .instock ? AppColors.primary : AppColors.textMuted).cornerRadius(AppStyles.BorderRadius.large)
            if let error = addToCartError {
                Text(error).font(AppFonts.roboto(size: AppFonts.Size.caption)).foregroundColor(AppColors.error)
            }
        }
    }
}
