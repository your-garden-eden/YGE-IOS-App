//
//  CartItemRow.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 30.05.25.
//
import SwiftUI

struct CartItemRow: View {
    let item: WooCommerceStoreCartItem
    @ObservedObject var viewModel: CartViewModel

    @State private var quantity: Int
    @State private var quantityUpdateTimer: Timer?

    init(item: WooCommerceStoreCartItem, viewModel: CartViewModel) {
        self.item = item
        self.viewModel = viewModel
        _quantity = State(initialValue: item.quantity)
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppStyles.Spacing.medium) {
            AsyncImage(url: item.images.first?.thumbnail.asURL()) { phase in
                switch phase {
                case .empty:
                    ZStack { AppColors.backgroundLightGray; ProgressView().tint(AppColors.primary) }
                        .frame(width: 80, height: 80).cornerRadius(AppStyles.BorderRadius.small)
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80).cornerRadius(AppStyles.BorderRadius.small).clipped()
                case .failure:
                    ZStack { AppColors.backgroundLightGray; Image(systemName: "photo.fill").resizable().scaledToFit().foregroundColor(AppColors.textMuted.opacity(0.7)).padding(15) }
                        .frame(width: 80, height: 80).cornerRadius(AppStyles.BorderRadius.small)
                @unknown default: EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: AppStyles.Spacing.xSmall) {
                Text(item.name)
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold))
                    .foregroundColor(AppColors.textHeadings)
                    .lineLimit(2)

                if !item.variation.isEmpty {
                    ForEach(item.variation, id: \.attribute) { variationAttr in
                        Text("\(variationAttr.attribute.displayableAttributeName()): \(variationAttr.value.capitalized)")
                            .font(AppFonts.roboto(size: AppFonts.Size.caption))
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                
                if let prices = item.prices {
                     Text("Preis: \(viewModel.currencySymbol)\(prices.price)")
                        .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .medium))
                        .foregroundColor(AppColors.textBase)
                }

                HStack(spacing: AppStyles.Spacing.small) {
                    Text("Menge:")
                        .font(AppFonts.roboto(size: AppFonts.Size.smallBody))
                    Button { changeQuantity(by: -1) } label: { Image(systemName: "minus.circle") }
                        .disabled(quantity <= 1 && (item.soldIndividually ?? false) )
                        .disabled(quantity <= 0 && !(item.soldIndividually ?? false) )
                    Text("\(quantity)")
                         .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                         .frame(minWidth: 25, alignment: .center)
                    Button { changeQuantity(by: 1) } label: { Image(systemName: "plus.circle") }
                }
                .buttonStyle(.borderless).foregroundColor(AppColors.primaryDark)
                .padding(.top, AppStyles.Spacing.xxSmall)
            }
            Spacer()
            Text("\(viewModel.currencySymbol)\(item.totals.lineTotal)")
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                .foregroundColor(AppColors.textHeadings)
        }
        .padding(.vertical, AppStyles.Spacing.small)
        .onReceive(viewModel.cartAPIManager.$currentCart) { updatedCart in
            if let currentItemInCart = updatedCart?.items.first(where: { $0.key == item.key }), currentItemInCart.quantity != self.quantity {
                self.quantity = currentItemInCart.quantity
            }
        }
        .onDisappear {
            quantityUpdateTimer?.invalidate()
            quantityUpdateTimer = nil
        }
    }
    
    private func changeQuantity(by amount: Int) {
        let newQuantityProposal = quantity + amount
        let finalNewQuantity: Int
        
        if item.soldIndividually ?? false {
            if amount < 0 { finalNewQuantity = 0 }
            else if amount > 0 && quantity >= 1 { print("CartItemRow (\(item.name)): Sold individually, cannot increase."); return }
            else { finalNewQuantity = 1 }
        } else {
            finalNewQuantity = max(0, newQuantityProposal) // Stellt sicher, dass es nicht negativ wird
        }

        if finalNewQuantity > 0 || (finalNewQuantity == 0 && quantity > 0) {
            self.quantity = finalNewQuantity
        }

        quantityUpdateTimer?.invalidate()
        
        if finalNewQuantity == 0 && quantity > 0 { // Wenn Menge auf 0 reduziert wurde (war vorher >0)
             print("CartItemRow (\(item.name)): Quantity reduced to 0. Requesting item removal for key \(item.key)")
            Task { @MainActor in viewModel.removeItem(itemKey: item.key) }
        } else if finalNewQuantity > 0 { // Nur aktualisieren, wenn die neue Menge > 0 ist
            quantityUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { [self] _ in
                let quantityToSend = self.quantity
                if quantityToSend > 0 {
                    print("CartItemRow (\(item.name)): Debounced quantity update to \(quantityToSend) for itemKey \(item.key)")
                    Task { @MainActor in viewModel.updateQuantity(for: item.key, newQuantity: quantityToSend) }
                }
            }
        }
    }
}

// Preview Provider für CartView
struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = FirebaseAuthManager.shared
        let cartAPIManager = CartAPIManager.shared
        // Für eine aussagekräftige Preview könntest du hier den cartAPIManager mit Mock-Daten füllen,
        // aber wir haben vereinbart, das zu vermeiden.
        // Du siehst also wahrscheinlich den Leerzustand oder Ladezustand in der Preview.
        CartView()
            .environmentObject(authManager)
            .environmentObject(cartAPIManager)
            // WishlistState wird für die CartView nicht direkt benötigt, es sei denn, du hast
            // Herz-Icons auch im Warenkorb, was unüblich ist.
    }
}
