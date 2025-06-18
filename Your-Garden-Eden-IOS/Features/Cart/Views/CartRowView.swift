// DATEI: CartRowView.swift
// PFAD: Features/Cart/Views/Components/CartRowView.swift
// ZWECK: Stellt einen einzelnen Artikel (eine Zeile) im Warenkorb dar.

import SwiftUI

struct CartRowView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    let item: Item
    
    // KORREKTUR: Kein lokaler @State mehr für die Menge.
    // Die View zeigt immer die Menge an, die vom Manager kommt.
    private var quantity: Int { item.quantity }
    
    private var isUpdatingThisItem: Bool {
        cartManager.state.updatingItemKey == item.key
    }

    var body: some View {
        HStack(spacing: AppTheme.Layout.Spacing.medium) {
            productImage
                .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.xSmall) {
                Text(item.name.strippingHTML())
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body, weight: .semibold))
                    .lineLimit(2)
                
                Text(PriceFormatter.formatPrice(
                    item.totals.line_total ?? "0.00",
                    currencySymbol: item.prices?.currency_symbol ?? AppConfig.WooCommerce.defaultCurrencySymbol
                ))
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .bold))
                    .foregroundColor(AppTheme.Colors.primary)
                
                Spacer(minLength: 4)
                
                quantityControl
            }
            
            Spacer()
        }
        .padding(AppTheme.Layout.Spacing.small)
        .background(AppTheme.Colors.backgroundComponent)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.small)
        .opacity(isUpdatingThisItem ? 0.5 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isUpdatingThisItem)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { await cartManager.removeItem(key: item.key) }
            } label: {
                Label("Löschen", systemImage: "trash.fill")
            }
            .disabled(isUpdatingThisItem)
        }
    }
    
    @ViewBuilder
    private var productImage: some View {
        // Sicherer Zugriff auf die Bild-URL
        if let url = item.images.first?.thumbnail?.asURL() {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                     Rectangle().fill(AppTheme.Colors.backgroundLightGray)
                        .overlay(Image(systemName: "photo.fill").font(.title).foregroundColor(AppTheme.Colors.borderLight))
                } else {
                    ProgressView().tint(AppTheme.Colors.primary)
                }
            }
        } else {
            Rectangle().fill(AppTheme.Colors.backgroundLightGray)
               .overlay(Image(systemName: "photo.fill").font(.title).foregroundColor(AppTheme.Colors.borderLight))
        }
    }
    
    @ViewBuilder
    private var quantityControl: some View {
        HStack {
            if isUpdatingThisItem {
                ProgressView().tint(AppTheme.Colors.primary)
                Text("Aktualisiere...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, AppTheme.Layout.Spacing.small)
            } else {
                HStack(spacing: AppTheme.Layout.Spacing.medium) {
                    Button(action: {
                        // Delegiert die Aktion direkt an den Manager.
                        if quantity > 1 {
                            Task { await cartManager.updateQuantity(for: item.key, newQuantity: quantity - 1) }
                        }
                    }) { Image(systemName: "minus") }.disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .bold))
                        .frame(minWidth: 25)
                    
                    Button(action: {
                        // Delegiert die Aktion direkt an den Manager.
                        Task { await cartManager.updateQuantity(for: item.key, newQuantity: quantity + 1) }
                    }) { Image(systemName: "plus") }
                }
                .buttonStyle(AppTheme.QuantityButtonStyle())
                .disabled(isUpdatingThisItem)
            }
        }
    }
}
