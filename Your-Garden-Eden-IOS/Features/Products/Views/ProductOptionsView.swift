// Path: Your-Garden-Eden-IOS/Features/Products/ProductOptionsView.swift

import SwiftUI

struct ProductOptionsView: View {
    @StateObject private var viewModel: ProductOptionsViewModel
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartManager: CartAPIManager

    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        _viewModel = StateObject(wrappedValue: ProductOptionsViewModel(
            product: product,
            variations: variations
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppStyles.Spacing.large) {
                    gallery
                    header
                    Divider()
                    attributeSelectors
                }
                .padding(.bottom, 150) // Space for bottom bar
            }
            .safeAreaInset(edge: .bottom) {
                addToCartSection
            }
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Optionen wählen")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: cartManager.state.errorMessage) { _, error in
            viewModel.addToCartError = error
        }
        .onChange(of: cartManager.state.items) { _, _ in
            if cartManager.state.errorMessage == nil {
                dismiss() // Success!
            }
        }
    }
    
    private var gallery: some View {
        AsyncImage(url: viewModel.currentImage?.src.asURL()) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFit()
            default: ProgressView().frame(height: 300)
            }
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.backgroundLightGray)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            Text(viewModel.product.name.strippingHTML())
                .font(AppFonts.montserrat(size: AppFonts.Size.h5, weight: .bold))
            
            HStack(spacing: AppStyles.Spacing.medium) {
                Text(viewModel.displayPrice.display)
                    .font(AppFonts.roboto(size: AppFonts.Size.h5, weight: .bold))
                    .foregroundColor(AppColors.price)
                if let strikethrough = viewModel.displayPrice.strikethrough {
                    Text(strikethrough)
                        .font(AppFonts.roboto(size: AppFonts.Size.body))
                        .strikethrough()
                        .foregroundColor(AppColors.textMuted)
                }
            }

            Text(viewModel.stockStatusMessage.text)
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                .foregroundColor(viewModel.stockStatusMessage.color)
        }
        .padding(.horizontal)
    }
    
    private var attributeSelectors: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.large) {
            ForEach(viewModel.displayableAttributes) { attribute in
                AttributeSelectorView(
                    attribute: attribute,
                    availableOptionSlugs: viewModel.availability[attribute.slug] ?? [],
                    selectedOptionSlug: viewModel.selectedAttributes[attribute.slug],
                    onSelect: { optionSlug in
                        viewModel.select(attributeSlug: attribute.slug, optionSlug: optionSlug)
                    }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var addToCartSection: some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            if !viewModel.product.soldIndividually {
                QuantitySelectorView(quantity: $viewModel.quantity)
                    .padding(.horizontal)
            }
            
            Button(action: { Task { await viewModel.handleAddToCart() } }) {
                if cartManager.state.isLoading { ProgressView().tint(.white) }
                else { Text("In den Warenkorb") }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.isAddToCartDisabled || cartManager.state.isLoading)
            
            if let error = viewModel.addToCartError {
                Text(error)
                    .font(.caption).foregroundColor(.red).multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(.regularMaterial)
    }
}
