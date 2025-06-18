// DATEI: CartView.swift
// PFAD: Features/Cart/Views/CartView.swift
// VERSION: 1.2 (FINAL & ANGEPASST)
// ZWECK: Die Hauptansicht für den Warenkorb, jetzt mit Logo-Header und Zurück-Button.

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    @Environment(\.selectedTab) private var selectedTab

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()

            if cartManager.state.isLoading && cartManager.state.items.isEmpty {
                initialLoadingView
            } else if cartManager.state.items.isEmpty {
                emptyCartView
            } else {
                cartContentView
            }
        }
        // KORREKTUR: Der explizite Navigationstitel wurde entfernt.
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await cartManager.getCart()
        }
        // KORREKTUR: Das Logo wird als primäres Toolbar-Element hinzugefügt.
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
        // KORREKTUR: Der Zurück-Button wird wie befohlen hinzugefügt.
        .customBackButton()
    }
    
    // MARK: - Subviews für verschiedene Zustände
    
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
            if let totals = cartManager.state.totals {
                cartTotalsView(totals: totals)
            }
        }
    }

    private var initialLoadingView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            ProgressView().tint(AppTheme.Colors.primary)
            Text("Lade Warenkorb...").foregroundColor(AppTheme.Colors.textMuted)
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Image(systemName: "cart")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(AppTheme.Colors.textMuted)
            
            Text("Dein Warenkorb ist leer")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold))
            
            Button("Weiter einkaufen") {
                self.selectedTab.wrappedValue = 1
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .padding(.top)
        }
        .padding()
    }
    
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
