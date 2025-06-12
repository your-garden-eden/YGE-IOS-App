// Features/Products/Views/ProductDetailView.swift

import SwiftUI

struct ProductDetailView: View {
    // Der Haupt-ViewModel, der die Daten lädt.
    @StateObject private var viewModel: ProductDetailViewModel
    @EnvironmentObject var wishlistState: WishlistState
    
    @State private var showAddedToCartConfirmation = false

    init(product: WooCommerceProduct) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    productGallery
                    productHeader
                    
                    // Zeige die Optionen nur an, wenn sie geladen sind.
                    if viewModel.isLoadingVariations {
                        ProgressView().frame(height: 100)
                    } else if let optionsVM = viewModel.optionsViewModel {
                        // GEÄNDERT: Delegiert an den neuen ViewModel
                        OptionsSectionView(viewModel: optionsVM)
                    } else if let error = viewModel.loadingError {
                        Text(error).foregroundColor(.red).padding()
                    }
                    
                    Divider()
                    descriptionSection
                    
                    Spacer(minLength: 140)
                }
            }
            
            // GEÄNDERT: Die Logik kommt jetzt vom optionsViewModel
            if let optionsVM = viewModel.optionsViewModel {
                AddToCartSectionView(viewModel: optionsVM, showConfirmation: $showAddedToCartConfirmation)
            }
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle(viewModel.product.name.strippingHTML())
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadVariationsIfNeeded() } // Startet den Ladevorgang
        .overlay(addedToCartBanner)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder private var productGallery: some View {
        // GEÄNDERT: Das Bild kommt jetzt auch vom optionsViewModel, wenn verfügbar.
        let imageURL = viewModel.optionsViewModel?.currentImage?.src.asURL() ?? viewModel.product.images.first?.src.asURL()
        
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted)
            default:
                ProgressView()
            }
        }
        .frame(minHeight: 300)
        .background(AppColors.backgroundComponent)
    }
    
    @ViewBuilder private var productHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(viewModel.product.name.strippingHTML()).font(.largeTitle.weight(.bold))
                Spacer()
                Button(action: { wishlistState.toggleWishlistStatus(for: viewModel.product) }) {
                    Image(systemName: wishlistState.isProductInWishlist(productId: viewModel.product.id) ? "heart.fill" : "heart")
                        .symbolRenderingMode(.multicolor)
                }
                .font(.title)
                .animation(.spring(), value: wishlistState.isProductInWishlist(productId: viewModel.product.id))
            }
            
            // GEÄNDERT: Der Preis kommt jetzt auch vom optionsViewModel.
            Text(viewModel.optionsViewModel?.displayPrice ?? viewModel.initialDisplayPrice)
                .font(.title2.weight(.semibold))
                .foregroundColor(AppColors.price)
                .animation(.easeInOut, value: viewModel.optionsViewModel?.displayPrice)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Beschreibung").font(.headline)
            // GEÄNDERT: Die Beschreibung passt sich der Auswahl an.
            let description = viewModel.optionsViewModel?.selectedVariation?.description ?? viewModel.product.description
            ExpandableText(text: description.strippingHTML(), lineLimit: 4)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder private var addedToCartBanner: some View {
        if showAddedToCartConfirmation {
            Text("Zum Warenkorb hinzugefügt")
                .fontWeight(.semibold).padding().background(Color.green)
                .foregroundColor(.white).cornerRadius(12).shadow(radius: 10)
                .transition(.move(edge: .top).combined(with: .opacity))
                .frame(maxHeight: .infinity, alignment: .top).padding(.top)
        }
    }
}


// MARK: - Neue, ausgelagerte Subviews für die Klarheit

private struct OptionsSectionView: View {
    @ObservedObject var viewModel: ProductOptionsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.displayableAttributes) { attribute in
                VStack(alignment: .leading, spacing: 5) {
                    Text(attribute.name).font(.headline)
                    
                    let selection = Binding<String?>(
                        get: { viewModel.selectedAttributes[attribute.slug] },
                        set: { viewModel.select(attributeSlug: attribute.slug, optionSlug: $0) }
                    )
                    
                    Picker(attribute.name, selection: selection) {
                        Text("Bitte wählen").tag(nil as String?)
                        ForEach(attribute.options) { option in
                            Text(option.name).tag(option.slug as String?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct AddToCartSectionView: View {
    @ObservedObject var viewModel: ProductOptionsViewModel
    @Binding var showConfirmation: Bool

    var body: some View {
        VStack(spacing: 12) {
            if !viewModel.product.soldIndividually {
                QuantitySelectorView(quantity: $viewModel.quantity)
                    .padding(.horizontal)
            }
            
            Button(action: {
                Task {
                    let success = await viewModel.handleAddToCart()
                    if success {
                        withAnimation { showConfirmation = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { showConfirmation = false }
                        }
                    }
                }
            }) {
                HStack {
                    if viewModel.isAddingToCart {
                        ProgressView().tint(.white)
                    } else {
                        Text("In den Warenkorb")
                    }
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
            .controlSize(.large)
            .disabled(viewModel.isAddToCartDisabled || viewModel.isAddingToCart)
            
            if let error = viewModel.addToCartError {
                Text(error).font(.caption).foregroundColor(.red)
            }
        }
        .padding()
        .background(.thinMaterial)
    }
}
