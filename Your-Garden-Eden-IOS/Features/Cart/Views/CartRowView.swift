
// DATEI: CartRowView.swift
// PFAD: Features/Cart/Views/Components/CartRowView.swift
// VERSION: 1.1 (SYNCHRONISIERT)

import SwiftUI

struct CartRowView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    let item: Item
    
    @Binding var path: NavigationPath
    
    private var isUpdatingThisItem: Bool {
        cartManager.state.updatingItemKey == item.key
    }

    var body: some View {
        HStack(spacing: AppTheme.Layout.Spacing.medium) {
            Button(action: {
                if let product = getProductDetails() {
                    path.append(product)
                }
            }) {
                HStack(alignment: .top, spacing: AppTheme.Layout.Spacing.medium) {
                    productImage
                        .frame(width: 90, height: 90)

                    VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xSmall) {
                        Text(item.name.strippingHTML())
                            .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .semibold))
                            .lineLimit(2)
                        
                        if let variations = item.variation, !variations.isEmpty {
                            ForEach(variations, id: \.attribute) { variation in
                                Text("\(variation.attribute ?? ""): \(variation.value ?? "")")
                                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption))
                            }
                        }
                        
                        Spacer()
                        
                        Text(PriceFormatter.formatPriceFromMinorUnit(
                            value: item.totals.line_total ?? "0",
                            minorUnit: cartManager.state.totals?.currency_minor_unit ?? 2
                        ))
                            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .bold))
                    }
                    .foregroundColor(AppTheme.Colors.textHeadings)
                    .frame(height: 90)
                }
            }
            .buttonStyle(.plain)
            .disabled(isUpdatingThisItem)

            Spacer()
            
            VStack {
                 Spacer()
                 HStack(spacing: AppTheme.Layout.Spacing.medium) {
                     Button(action: { updateQuantity(by: -1) }) {
                         Image(systemName: "minus.circle.fill")
                     }
                     .disabled(item.quantity <= 1 || isUpdatingThisItem)
                     
                     Text("\(item.quantity)")
                         .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.title2, weight: .semibold))
                         .frame(minWidth: 30, alignment: .center)
                     
                     Button(action: { updateQuantity(by: 1) }) {
                         Image(systemName: "plus.circle.fill")
                     }
                     .disabled(isUpdatingThisItem)
                 }
                 .font(.title2)
                 .foregroundColor(AppTheme.Colors.primaryDark)
                 Spacer()
            }
        }
        .padding(AppTheme.Layout.Spacing.small)
        .background(AppTheme.Colors.backgroundComponent)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.small)
        .overlay {
            if isUpdatingThisItem {
                ProgressView().tint(AppTheme.Colors.primary)
            }
        }
        .opacity(isUpdatingThisItem ? 0.6 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isUpdatingThisItem)
    }
    
    @ViewBuilder
    private var productImage: some View {
        ZStack {
            // KORREKTUR: Das Feld 'thumbnail' existiert im gehärteten 'WooCommerceImage'-Modell nicht mehr.
            // Der Zugriff erfolgt nun auf das zuverlässige 'src'-Feld.
            if let url = item.images.first?.src.asURL() {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(AppTheme.Colors.backgroundLightGray).overlay(Image(systemName: "photo.fill").font(.title).foregroundColor(AppTheme.Colors.borderLight))
                    }
                }
            } else {
                Rectangle().fill(AppTheme.Colors.backgroundLightGray).overlay(Image(systemName: "photo.fill").font(.title).foregroundColor(AppTheme.Colors.borderLight))
            }
        }
        .cornerRadius(AppTheme.Layout.BorderRadius.medium)
        .clipped()
    }
    
    private func updateQuantity(by amount: Int) {
        let newQuantity = item.quantity + amount
        guard newQuantity > 0 else { return }
        Task {
            await cartManager.updateQuantity(for: item.key, newQuantity: newQuantity)
        }
    }
    
    private func getProductDetails() -> WooCommerceProduct? {
        let parentProductId = cartManager.state.variationToParentMap[item.id] ?? item.id
        return cartManager.state.productDetails[parentProductId]
    }
}

