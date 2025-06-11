import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @EnvironmentObject var wishlistState: WishlistState
    @State private var quantity: Int = 1
    
    @State private var isDescriptionExpanded = false
    
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
                    
                    if let description = viewModel.formattedDescription, !description.characters.isEmpty {
                        productDescriptionView(description: description)
                            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(AppColors.backgroundComponent)
                    }
                    
                    if !viewModel.displayRelatedProducts.isEmpty {
                        relatedProductsSection
                            .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    
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
        }
    }
    
    @ViewBuilder
    private func productDescriptionView(description: AttributedString) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Beschreibung")
                .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            
            Text(description)
                .font(.body)
                .foregroundColor(AppColors.textMuted)
                .lineLimit(isDescriptionExpanded ? nil : 5)
            
            Button(action: {
                withAnimation(.easeInOut) {
                    isDescriptionExpanded.toggle()
                }
            }) {
                Text(isDescriptionExpanded ? "Weniger anzeigen" : "Mehr lesen...")
                    .font(.caption.weight(.bold))
                    .foregroundColor(AppColors.textLink)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var relatedProductsSection: some View {
        VStack(alignment: .leading) {
            Text("Was Kunden auch kaufen")
                .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
                .padding(.horizontal)
            
            RelatedProductsView(products: viewModel.displayRelatedProducts)
        }
    }

    @ViewBuilder
    private func productGalleryView(allImages: [WooCommerceImage]) -> some View {
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
        Text(viewModel.displayPrice).font(.title2.weight(.bold)).foregroundColor(AppColors.price)
    }

    @ViewBuilder
    private func actionButtonSection(product: WooCommerceProduct) -> some View {
        VStack(spacing: 20) {
            if product.type == .variable {
                NavigationLink(destination: ProductOptionsView(product: product, variations: viewModel.variations)) {
                    Text("Optionen wählen").font(.headline.weight(.bold)).foregroundColor(AppColors.textOnPrimary).frame(maxWidth: .infinity).padding().background(AppColors.primary).cornerRadius(AppStyles.BorderRadius.large)
                }.disabled(viewModel.variations.isEmpty && viewModel.isLoading)
            } else {
                // KORREKTUR: Der alte Stepper wird durch unsere neue, benutzerdefinierte View ersetzt.
                if product.soldIndividually == false {
                    quantitySelector()
                }
                
                Button(action: {
                    Task {
                        isAddingToCart = true
                        addToCartError = nil
                        do {
                            try await CartAPIManager.shared.addItem(productId: product.id, quantity: quantity)
                            isAddingToCart = false
                        } catch {
                            addToCartError = "Produkt konnte nicht hinzugefügt werden."
                            isAddingToCart = false
                        }
                    }
                }) {
                    if isAddingToCart {
                        ProgressView().tint(AppColors.textOnPrimary).frame(maxWidth: .infinity).padding()
                    } else {
                        Text("In den Warenkorb").font(.headline.weight(.bold)).foregroundColor(AppColors.textOnPrimary).frame(maxWidth: .infinity).padding()
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
    
    // NEU: Ein benutzerdefinierter "Quantity Selector", der den Stepper ersetzt.
    @ViewBuilder
    private func quantitySelector() -> some View {
        HStack {
            Text("Menge")
                .font(.headline.weight(.semibold))

            Spacer()

            // Minus-Button
            Button(action: {
                if quantity > 1 {
                    quantity -= 1
                }
            }) {
                Image(systemName: "minus.circle.fill")
            }
            // Button wird deaktiviert, wenn die Menge 1 ist.
            .disabled(quantity <= 1)
            // Die Opazität sorgt für einen weicheren "deaktiviert"-Effekt als das harte Ausgrauen.
            .opacity(quantity <= 1 ? 0.4 : 1.0)

            // Anzeige der Menge
            Text("\(quantity)")
                .font(.title3.weight(.bold))
                .frame(minWidth: 40, alignment: .center) // Gibt der Zahl Platz

            // Plus-Button
            Button(action: {
                // Begrenzt die maximale Menge (hier auf 10, kann angepasst werden)
                if quantity < 10 {
                    quantity += 1
                }
            }) {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(quantity >= 10)
            .opacity(quantity >= 10 ? 0.4 : 1.0)
        }
        .font(.title2) // Steuert die Größe der Icons
        .foregroundColor(AppColors.primaryDark) // Setzt die Farbe für die Icons
        .buttonStyle(.plain) // Sorgt dafür, dass die Buttons keinen eigenen Hintergrund bekommen
    }
}
