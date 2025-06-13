// Dateiname: Features/Cart/CartView.swift

import SwiftUI

struct CartView: View {
    
    @EnvironmentObject private var cartManager: CartAPIManager
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var isShowingAuthSheet = false
    
    // KORREKTUR: Wir definieren den Environment-Key hier explizit.
    // Dies macht den Code robuster, falls Sie die Definitionsdatei mal ändern.
    @Environment(\.selectedTab) private var selectedTab

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPage.ignoresSafeArea()

                if cartManager.items.isEmpty && !cartManager.isLoading {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .overlay {
                if cartManager.isLoading && cartManager.items.isEmpty {
                    VStack {
                        ProgressView().tint(AppColors.primary)
                        Text("Lade Warenkorb...").font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).padding(.top)
                    }
                }
            }
            .navigationTitle("Warenkorb")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .principal) {
                     Text("Warenkorb").font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold)).foregroundColor(AppColors.textHeadings)
                 }
            }
            .refreshable { await cartManager.getCart() }
            .sheet(isPresented: $isShowingAuthSheet) {
                AuthContainerView(onDismiss: { isShowingAuthSheet = false }).environmentObject(authManager)
            }
            .navigationDestination(for: CheckoutView.self) { checkoutView in
                checkoutView
            }
        }
    }
    
    @ViewBuilder
    private var cartContentView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(cartManager.items) { item in
                    CartRowView(item: item) { newQuantity in
                        updateItemQuantity(for: item, to: newQuantity)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                deleteItem(item)
                            }
                        } label: { Label("Löschen", systemImage: "trash.fill") }
                    }
                }
                .listRowBackground(AppColors.backgroundPage)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: AppStyles.Spacing.small, leading: 0, bottom: AppStyles.Spacing.small, trailing: 0))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.horizontal)

            if let totals = cartManager.totals {
                cartTotalsView(totals: totals)
            }
        }
    }
    
    private func cartTotalsView(totals: Totals) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            HStack {
                Text("Zwischensumme").font(AppFonts.roboto(size: AppFonts.Size.body))
                Spacer()
                Text(totals.totalItemsPriceFormatted).font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
            }
            HStack {
                Text("Versand").font(AppFonts.roboto(size: AppFonts.Size.body))
                Spacer()
                Text(totals.totalShippingFormatted).font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
            }
            
            Divider().padding(.vertical, AppStyles.Spacing.xSmall)
            
            HStack {
                Text("Gesamt").font(AppFonts.montserrat(size: AppFonts.Size.title3, weight: .bold))
                Spacer()
                Text(totals.totalPriceFormatted).font(AppFonts.montserrat(size: AppFonts.Size.title3, weight: .bold))
            }
            
            checkoutButton.padding(.top, AppStyles.Spacing.small)
        }
        .padding()
        .background(AppColors.backgroundComponent)
    }
    
    @ViewBuilder
    private var checkoutButton: some View {
        if authManager.isLoggedIn {
            NavigationLink(value: CheckoutView()) { Text("Zur Kasse") }.buttonStyle(PrimaryButtonStyle())
        } else {
            Button("Anmelden & zur Kasse") { isShowingAuthSheet = true }.buttonStyle(PrimaryButtonStyle())
        }
    }
    
    @ViewBuilder
    private var emptyCartView: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "cart.fill").font(.system(size: 60)).foregroundColor(AppColors.primary.opacity(0.5))
            Text("Dein Warenkorb ist leer").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold)).foregroundColor(AppColors.textHeadings)
            Text("Füge Produkte hinzu, um sie hier zu sehen.").font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center)
            Button("Weiter einkaufen") {
                // KORREKTUR: Wir greifen direkt auf das 'wrappedValue' des Bindings zu,
                // um den Tab-Index zu ändern. Keine 'if let'-Prüfung nötig.
                self.selectedTab.wrappedValue = 0 // Gehe zum ersten Tab (Home/Shop)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
            .controlSize(.large)
            .padding(.top)
        }
        .padding()
    }
    
    // MARK: - Private Helper Functions
    
    private func updateItemQuantity(for item: Item, to newQuantity: Int) {
        Task {
            await cartManager.updateQuantity(for: item, newQuantity: newQuantity)
        }
    }
    
    private func deleteItem(_ item: Item) {
        Task {
            await cartManager.removeItem(item)
        }
    }
}

// Definition des Environment-Keys. Diese sollte in einer eigenen Datei liegen.
// Wenn sie nicht existiert, fügen Sie diesen Code in eine neue Datei ein, z.B. "EnvironmentValues+Extensions.swift".
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}


