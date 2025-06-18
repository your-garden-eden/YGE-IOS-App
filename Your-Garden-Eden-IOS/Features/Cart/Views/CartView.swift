// DATEI: CartView.swift
// PFAD: Features/Cart/Views/CartView.swift
// ZWECK: Die Hauptansicht für den Warenkorb. Dient als Container und
//        delegiert die Anzeige der verschiedenen Zustände an spezialisierte Unter-Views.

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    
    // Environment-Binding, um bei Klick auf "Weiter einkaufen" den Tab wechseln zu können.
    @Environment(\.selectedTab) private var selectedTab

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()

            // Die View entscheidet basierend auf dem Zustand des Managers, welche Unter-View angezeigt wird.
            if cartManager.state.isLoading && cartManager.state.items.isEmpty {
                initialLoadingView
            } else if cartManager.state.items.isEmpty {
                emptyCartView
            } else {
                cartContentView
            }
        }
        .navigationTitle("Warenkorb")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await cartManager.getCart()
        }
    }
    
    // MARK: - Subviews für verschiedene Zustände
    
    /// Zeigt eine Liste der Warenkorb-Artikel und die Gesamtsumme an.
    private var cartContentView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Layout.Spacing.medium) {
                ForEach(cartManager.state.items) { item in
                    CartRowView(item: item)
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            // Die Gesamtsumme und der Checkout-Button werden am unteren Rand "angedockt".
            if let totals = cartManager.state.totals {
                cartTotalsView(totals: totals)
            }
        }
    }

    /// Die Ansicht, die angezeigt wird, wenn der Warenkorb initial geladen wird.
    private var initialLoadingView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            ProgressView().tint(AppTheme.Colors.primary)
            Text("Lade Warenkorb...").foregroundColor(AppTheme.Colors.textMuted)
        }
    }
    
    /// Die Ansicht, die angezeigt wird, wenn der Warenkorb leer ist.
    private var emptyCartView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Image(systemName: "cart")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(AppTheme.Colors.textMuted)
            
            Text("Dein Warenkorb ist leer")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold))
            
            Button("Weiter einkaufen") {
                // Wechselt zum "Shop"-Tab (Index 1).
                self.selectedTab.wrappedValue = 1
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .padding(.top)
        }
        .padding()
    }
    
    /// Die Ansicht am unteren Rand, die die Gesamtsumme und den Checkout-Button anzeigt.
    private func cartTotalsView(totals: Totals) -> some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            if let error = cartManager.state.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.error)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Text("Gesamt")
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .bold))
                Spacer()
                Text(totals.totalPriceFormatted)
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.headline, weight: .bold))
            }
            
            // Nutzt den typsicheren `AppDestination`-Wert für die Navigation.
            NavigationLink(value: AppDestination.checkout) {
                 Text("Zur Kasse")
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(cartManager.state.items.isEmpty)
        }
        .padding()
        .background(.regularMaterial)
    }
}
