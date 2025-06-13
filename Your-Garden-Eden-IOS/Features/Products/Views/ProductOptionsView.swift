// Dateiname: ProductOptionsView.swift

import SwiftUI

struct ProductOptionsView: View {
    @StateObject private var viewModel: ProductOptionsViewModel
    
    // Wir brauchen den CartAPIManager, um den Fehlerzustand zu prüfen.
    @EnvironmentObject var cartAPIManager: CartAPIManager
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
                    // Platzhalter am Ende, damit die untere Leiste den Inhalt nicht verdeckt
                    Spacer(minLength: 140)
                }
            }
            .background(AppColors.backgroundPage.ignoresSafeArea())
            
            addToCartSection
        }
        .navigationTitle("Optionen wählen")
        .navigationBarTitleDisplayMode(.inline)
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
            Text(viewModel.product.name.strippingHTML())
                .font(AppFonts.montserrat(size: AppFonts.Size.title1, weight: .bold))
                .foregroundColor(AppColors.textHeadings)
            
            Text(viewModel.displayPrice)
                .font(AppFonts.roboto(size: AppFonts.Size.title2, weight: .bold))
                .foregroundColor(AppColors.price)
        }
        .padding(.horizontal)
    }
    
    private var attributesSection: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
            ForEach(viewModel.displayableAttributes) { attribute in
                AttributeSelectorView(
                    attribute: attribute,
                    availableOptionSlugs: viewModel.availableOptionSlugs(for: attribute),
                    currentlySelectedOptionSlugForThisAttribute: viewModel.selectedAttributes[attribute.name],
                    onOptionSelect: { selectedOptionSlug in
                        viewModel.select(attributeName: attribute.name, optionSlug: selectedOptionSlug)
                    }
                )
            }
        }
        .padding(.horizontal)
    }

    private var addToCartSection: some View {
        VStack(spacing: 12) {
            if !viewModel.product.soldIndividually {
                QuantitySelectorView(quantity: $viewModel.quantity)
                    .padding(.horizontal)
            }
            
            Button(action: {
                Task {
                    // Funktion aufrufen (gibt nichts mehr zurück)
                    await viewModel.handleAddToCart()
                    
                    // KORREKTUR: Prüfe den Zustand des CartAPIManager
                    if cartAPIManager.errorMessage == nil {
                        // Erfolg! Schließe die Ansicht.
                        dismiss()
                    }
                    // Der Fehlerzustand wird bereits vom ViewModel im 'addToCartError' angezeigt,
                    // also müssen wir hier nichts weiter tun.
                }
            }) {
                HStack {
                    if viewModel.isAddingToCart {
                        ProgressView().tint(AppColors.textOnPrimary)
                    } else {
                        Text("In den Warenkorb")
                    }
                }
                .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .bold))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isAddToCartDisabled ? AppColors.primaryLight : AppColors.primary)
            .controlSize(.large)
            .disabled(viewModel.isAddToCartDisabled || viewModel.isAddingToCart)
            
            if let error = viewModel.addToCartError {
                Text(error)
                    .font(AppFonts.roboto(size: AppFonts.Size.caption))
                    .foregroundColor(AppColors.error)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(.thinMaterial)
    }
}
