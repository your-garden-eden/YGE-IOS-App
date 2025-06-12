//
//  ProductOptionsView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

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
            // KORREKTUR: Die ForEach-Schleife verwendet jetzt die ID der Attribut-Struktur.
            ForEach(viewModel.displayableAttributes) { attribute in
                AttributeSelectorView(
                    attribute: attribute,
                    availableOptionSlugs: viewModel.availableOptionSlugs(for: attribute),
                    // KORREKTUR: Greift über den Attribut-NAMEN auf das Dictionary zu.
                    currentlySelectedOptionSlugForThisAttribute: viewModel.selectedAttributes[attribute.name],
                    onOptionSelect: { selectedOptionSlug in
                        // KORREKTUR: Ruft die `select`-Methode mit den korrekten Parameter-Namen auf.
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
                    let success = await viewModel.handleAddToCart()
                    if success {
                        dismiss()
                    }
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
