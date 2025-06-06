import SwiftUI

struct ProductOptionsView: View {
    @StateObject private var viewModel: ProductOptionsViewModel
    @Environment(\.dismiss) private var dismiss

    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        _viewModel = StateObject(wrappedValue: ProductOptionsViewModel(
            product: product,
            variations: variations
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    productImageView
                    productInfoView
                    Divider()
                    attributesSection
                    Spacer(minLength: 120)
                }
            }
            addToCartSection
        }
        .background(AppColors.backgroundPage)
        .navigationTitle("Optionen wählen")
        .navigationBarTitleDisplayMode(.inline)
        // Dieser Task wird ausgeführt, sobald die View erscheint,
        // um den initialen Preis korrekt und sicher zu berechnen.
        .task {
            await viewModel.updateState()
        }
    }
    
    // MARK: - Subviews
    
    private var productImageView: some View {
        AsyncImage(url: viewModel.currentImage?.src.asURL()) { phase in
            switch phase {
            case .success(let img): img.resizable().scaledToFit()
            case .failure, .empty: Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted).frame(maxWidth: .infinity, minHeight: 300)
            @unknown default: EmptyView()
            }
        }
        .frame(minHeight: 300)
        .background(AppColors.backgroundComponent)
    }
    
    private var productInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.product.name)
                .font(.title.weight(.bold))
                .foregroundColor(AppColors.textHeadings)
            
            // Zeigt jetzt die @Published-Eigenschaft aus dem ViewModel an.
            Text(viewModel.displayPrice)
                .font(.title2.weight(.bold))
                .foregroundColor(AppColors.price)
        }
        .padding(.horizontal)
    }
    
    private var attributesSection: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.product.attributes) { attribute in
                if let attributeSlug = attribute.slug {
                    AttributeSelectorView(
                        attribute: attribute,
                        availableOptionSlugs: viewModel.availableOptionSlugs(for: attribute),
                        currentlySelectedOptionSlugForThisAttribute: viewModel.selectedAttributes[attributeSlug],
                        onOptionSelect: { selectedOptionSlug in
                            // --- DIE KORREKTUR ---
                            // Wir wickeln den Aufruf der async-Funktion in einen Task.
                            Task {
                                await viewModel.select(attributeSlug: attributeSlug, optionSlug: selectedOptionSlug)
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal)
    }

    private var addToCartSection: some View {
        VStack(spacing: 16) {
            if viewModel.product.soldIndividually == false {
                Stepper("Menge: \(viewModel.quantity)", value: $viewModel.quantity, in: 1...10)
                    .font(.headline.weight(.semibold))
                    .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.addToCart()
                dismiss()
            }) {
                Text("In den Warenkorb")
                    .font(.headline.weight(.bold))
                    .foregroundColor(AppColors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(viewModel.isAddToCartDisabled ? AppColors.primaryLight : AppColors.primary)
            .cornerRadius(AppStyles.BorderRadius.large)
            .disabled(viewModel.isAddToCartDisabled)
        }
        .padding()
        .background(.thinMaterial)
    }
}
