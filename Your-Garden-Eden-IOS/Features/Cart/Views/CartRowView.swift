// DATEI: CartRowView.swift
// PFAD: Features/Cart/Views/Components/CartRowView.swift
// VERSION: 3.0 (FINAL & VISUELL ANGEGLICHEN)
// ZWECK: Stellt einen Artikel im Warenkorb dar, visuell angeglichen an die WishlistRowView,
//        mit einer integrierten, aber separaten Kontrollleiste.

import SwiftUI

struct CartRowView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    let item: Item
    
    private var isUpdatingThisItem: Bool {
        cartManager.state.updatingItemKey == item.key
    }

    var body: some View {
        VStack(spacing: 0) {
            // ===================================================================
            // **NEUE STRUKTUR: Ebene 1 - Informations-Anzeige**
            // Dieser Teil ist nun visuell identisch mit der WishlistRowView.
            // ===================================================================
            HStack(alignment: .top, spacing: AppTheme.Layout.Spacing.medium) {
                productImage
                    .frame(width: 90, height: 90)
                    .cornerRadius(AppTheme.Layout.BorderRadius.medium)

                VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xSmall) {
                    Text(item.name.strippingHTML())
                        .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textHeadings)
                        .lineLimit(2)
                    
                    // Zeigt ausgewählte Variationen an
                    if let variations = item.variation, !variations.isEmpty {
                        ForEach(variations, id: \.attribute) { variation in
                            Text("\(variation.attribute ?? ""): \(variation.value ?? "")")
                                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption))
                                .foregroundColor(AppTheme.Colors.textMuted)
                        }
                    }
                    
                    Spacer()
                    
                    Text(PriceFormatter.formatPrice(
                        item.totals.line_total ?? "0.00",
                        currencySymbol: item.prices?.currency_symbol ?? AppConfig.WooCommerce.defaultCurrencySymbol
                    ))
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .bold))
                        .foregroundColor(AppTheme.Colors.price)
                }
                .frame(height: 90)
            }
            .padding([.top, .leading, .trailing])
            
            // ===================================================================
            // **NEUE STRUKTUR: Ebene 2 - Interaktive Kontrollleiste**
            // ===================================================================
            HStack {
                if isUpdatingThisItem {
                    ProgressView().tint(AppTheme.Colors.primary)
                } else {
                    // Mengensteuerung
                    HStack(spacing: AppTheme.Layout.Spacing.medium) {
                        Button(action: { updateQuantity(by: -1) }) {
                            Image(systemName: "minus.circle.fill")
                        }
                        .disabled(item.quantity <= 1)
                        
                        Text("\(item.quantity)")
                            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.title2, weight: .semibold))
                            .frame(minWidth: 30, alignment: .center)
                        
                        Button(action: { updateQuantity(by: 1) }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .font(.title2)
                    .foregroundColor(AppTheme.Colors.primaryDark)
                }
                
                Spacer()
                
                // Expliziter Löschen-Button
                Button(role: .destructive) {
                    Task { await cartManager.removeItem(key: item.key) }
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.error)
                }
                .disabled(isUpdatingThisItem)
            }
            .padding([.horizontal, .bottom])
            .padding(.top, AppTheme.Layout.Spacing.small)
        }
        .background(AppTheme.Colors.backgroundComponent)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.small)
        .opacity(isUpdatingThisItem ? 0.5 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isUpdatingThisItem)
    }
    
    @ViewBuilder
    private var productImage: some View {
        if let url = item.images.first?.thumbnail?.asURL() {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle().fill(AppTheme.Colors.backgroundLightGray)
                       .overlay(Image(systemName: "photo.fill").font(.title).foregroundColor(AppTheme.Colors.borderLight))
                }
            }
        } else {
            Rectangle().fill(AppTheme.Colors.backgroundLightGray)
               .overlay(Image(systemName: "photo.fill").font(.title).foregroundColor(AppTheme.Colors.borderLight))
        }
    }
    
    private func updateQuantity(by amount: Int) {
        let newQuantity = item.quantity + amount
        guard newQuantity > 0 else { return }
        Task {
            await cartManager.updateQuantity(for: item.key, newQuantity: newQuantity)
        }
    }
}
