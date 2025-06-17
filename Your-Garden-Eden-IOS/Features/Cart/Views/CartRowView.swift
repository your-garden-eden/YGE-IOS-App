// Path: Your-Garden-Eden-IOS/Features/Cart/Views/CartRowView.swift
// VERSION 1.1 (FINAL - Synchronized with AppModels v2.9)

import SwiftUI

struct CartRowView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    
    let item: Item
    
    @State private var quantity: Int

    init(item: Item) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
    }

    private var isUpdating: Bool {
        cartManager.state.updatingItemKey == item.key
    }

    var body: some View {
        HStack(spacing: AppStyles.Spacing.medium) {
            productImage
                .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                Text(item.name.strippingHTML())
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold))
                    .lineLimit(2)
                
                // ===================================================================
                // **KORREKTUR 1:**
                // Greift auf den korrekten Eigenschaftsnamen `line_total` zu und
                // bietet einen Fallback-Wert, da die Eigenschaft optional ist.
                // ===================================================================
                Text(PriceFormatter.formatPrice(item.totals.line_total ?? "0.00", currencySymbol: item.prices?.currency_symbol ?? AppConfig.WooCommerce.defaultCurrencySymbol))
                    .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                    .foregroundColor(AppColors.primary)
                
                Spacer(minLength: 4)
                
                quantityControl
            }
            
            Spacer()
        }
        .padding(AppStyles.Spacing.small)
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        .appShadow(AppStyles.Shadows.small)
        .opacity(isUpdating ? 0.5 : 1.0)
        .animation(.easeOut(duration: 0.2), value: isUpdating)
        .onChange(of: item.quantity) { _, newServerQuantity in
            if self.quantity != newServerQuantity {
                self.quantity = newServerQuantity
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task { await cartManager.removeItem(item) }
            } label: {
                Label("Löschen", systemImage: "trash.fill")
            }
            .disabled(isUpdating)
        }
    }
    
    @ViewBuilder
    private var productImage: some View {
        // ===================================================================
        // **KORREKTUR 2:**
        // Wir entpacken die optionale URL sicher mit `if let`. Nur wenn
        // sowohl `thumbnail` als auch die `URL`-Konvertierung erfolgreich sind,
        // wird das AsyncImage initialisiert.
        // ===================================================================
        if let thumbnailURLString = item.images.first?.thumbnail, let url = thumbnailURLString.asURL() {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                     Rectangle().fill(AppColors.backgroundLightGray)
                        .overlay(Image(systemName: "photo.fill").font(.title).foregroundColor(AppColors.borderLight))
                } else {
                    ProgressView().tint(AppColors.primary)
                }
            }
        } else {
            // Zeigt ein Placeholder an, wenn die URL ungültig ist oder fehlt.
            Rectangle().fill(AppColors.backgroundLightGray)
               .overlay(Image(systemName: "photo.fill").font(.title).foregroundColor(AppColors.borderLight))
        }

        // --- Die folgenden Zeilen bleiben unverändert ---
        frame(width: 80, height: 80)
        .background(AppColors.backgroundLightGray)
        .cornerRadius(AppStyles.BorderRadius.medium)
        .clipped()
    }
    
    @ViewBuilder
    private var quantityControl: some View {
        HStack {
            if isUpdating {
                ProgressView().tint(AppColors.primary)
                Text("Aktualisiere...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, AppStyles.Spacing.small)
            } else {
                HStack(spacing: AppStyles.Spacing.medium) {
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                            Task { await cartManager.updateQuantity(for: item, newQuantity: quantity) }
                        }
                    }) {
                        Image(systemName: "minus")
                    }
                    .disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                        .frame(minWidth: 25)
                    
                    Button(action: {
                        quantity += 1
                        Task { await cartManager.updateQuantity(for: item, newQuantity: quantity) }
                    }) {
                        Image(systemName: "plus")
                    }
                }
                .buttonStyle(QuantityButtonStyle())
                .disabled(isUpdating)
            }
        }
    }
}

fileprivate struct QuantityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(AppColors.primary)
            .frame(width: 30, height: 30)
            .background(AppColors.primary.opacity(configuration.isPressed ? 0.2 : 0.1))
            .clipShape(Circle())
    }
}
