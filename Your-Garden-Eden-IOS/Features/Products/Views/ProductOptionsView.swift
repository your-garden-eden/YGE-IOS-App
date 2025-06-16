// Path: Your-Garden-Eden-IOS/Features/Products/Views/ProductOptionsView.swift
// VERSION 3.2 (FINAL - Uses CustomBackButtonModifier)

import SwiftUI

struct ProductOptionsView: View {
    
    @StateObject private var viewModel: ProductOptionsViewModel
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cartManager: CartAPIManager
    
    @State private var selectedImageID: Int?

    init(product: WooCommerceProduct, variations: [WooCommerceProductVariation]) {
        _viewModel = StateObject(wrappedValue: ProductOptionsViewModel(
            product: product,
            variations: variations
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppStyles.Spacing.xLarge) {
                    gallerySection
                    headerSection
                    Divider()
                    attributesSection
                }
                .padding(.bottom, 160)
            }
            .safeAreaInset(edge: .bottom) {
                addToCartSection
            }
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Optionen auswählen")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton() // WENDET DEN NEUEN MODIFIER AN
        .onAppear {
            self.selectedImageID = viewModel.product.safeImages.first?.id
        }
        .onChange(of: viewModel.currentImage) { _, newImage in
            withAnimation(.easeInOut) {
                self.selectedImageID = newImage?.id
            }
        }
        .onChange(of: cartManager.state.items) {
            if cartManager.state.errorMessage == nil {
                dismiss()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var gallerySection: some View {
        VStack(spacing: AppStyles.Spacing.small) {
            AsyncImage(url: (viewModel.currentImage ?? viewModel.product.safeImages.first)?.src.asURL()) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                default:
                    Rectangle()
                        .fill(AppColors.backgroundLightGray)
                        .overlay(ProgressView().tint(AppColors.primary))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 300)
            
            if viewModel.product.safeImages.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.product.safeImages) { image in
                            Button(action: {
                                withAnimation {
                                    self.selectedImageID = image.id
                                }
                            }) {
                                AsyncImage(url: image.src.asURL()) { phase in
                                    switch phase {
                                    case .success(let thumb):
                                        thumb.resizable().scaledToFill()
                                    default:
                                        Rectangle().fill(AppColors.borderLight)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(AppStyles.BorderRadius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                                        .stroke(selectedImageID == image.id ? AppColors.primary : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            Text(viewModel.product.name.strippingHTML())
                .font(AppFonts.montserrat(size: AppFonts.Size.h4, weight: .bold))
            
            let priceInfo = viewModel.displayPrice
            Text(priceInfo.display)
                .font(AppFonts.roboto(size: AppFonts.Size.h3, weight: .bold))
                .foregroundColor(AppColors.price)
        }
        .padding(.horizontal)
    }
    
    private var attributesSection: some View {
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
            Text(viewModel.stockStatusMessage.text)
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                .foregroundColor(viewModel.stockStatusMessage.color)
                .animation(.easeInOut, value: viewModel.stockStatusMessage.text)
            
            Button(action: { Task { await viewModel.handleAddToCart() } }) {
                if cartManager.state.isLoading { ProgressView().tint(.white) }
                else {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("In den Warenkorb")
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.isAddToCartDisabled)
            
            if let error = cartManager.state.errorMessage ?? viewModel.addToCartError {
                Text(error)
                    .font(.caption).foregroundColor(.red).multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight]) // Dieser Aufruf verursacht die Fehler
    }
}

// ===================================================================
// **DIESER TEIL HAT GEFEHLT UND BEHEBT DIE "corners"-FEHLER**
// ===================================================================

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
