// DATEI: CartView.swift
// PFAD: Features/Cart/Views/CartView.swift
// VERSION: FINAL (OPERATION GLEICHSCHALTUNG 2.0)
// ÄNDERUNG: Die Navigationslogik wurde an das neue, korrekte Mapping-System angepasst.

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    @Environment(\.selectedTab) private var selectedTab
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var showingAuthSheet = false
    @State private var isShowingClearCartAlert = false

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
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await cartManager.getCart()
        }
        .sheet(isPresented: $showingAuthSheet) {
            AuthContainerView(onDismiss: { self.showingAuthSheet = false })
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    selectedTab.wrappedValue = 1
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Zurück zum Shop")
                    }
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primaryDark)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Warenkorb leeren?", isPresented: $isShowingClearCartAlert) {
            Button("Löschen", role: .destructive) {
                Task { await cartManager.clearCart() }
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Möchten Sie wirklich alle Artikel aus Ihrem Warenkorb entfernen? Diese Aktion kann nicht widerrufen werden.")
        }
    }
    
    private var cartContentView: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Layout.Spacing.medium) {
                ForEach(cartManager.state.items) { item in
                    // Ermittle die korrekte Hauptprodukt-ID.
                    let parentProductId = cartManager.state.variationToParentMap[item.id] ?? item.id
                    
                    // Suche das Hauptprodukt im Cache.
                    if let product = cartManager.state.productDetails[parentProductId] {
                        NavigationLink(value: product) {
                            CartRowView(item: item)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Zeige die Zeile ohne Link an, falls die Daten noch nicht da sind.
                        CartRowView(item: item)
                    }
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
    
    @ViewBuilder
    private var emptyCartView: some View {
        if authManager.isLoggedIn {
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
        } else {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.questionmark.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.textMuted.opacity(0.7))
                
                Text("Anmelden für Warenkorb")
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h5, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textHeadings)
                
                Text("Um deinen Warenkorb geräteübergreifend zu speichern, melde dich bitte an.")
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Anmelden oder Registrieren") {
                    self.showingAuthSheet = true
                }
                .buttonStyle(AppTheme.PrimaryButtonStyle())
                .padding(.top)
            }
            .padding()
        }
    }
    
    private func cartTotalsView(totals: Totals) -> some View {
        VStack(spacing: AppTheme.Layout.Spacing.small) {
            if let error = cartManager.state.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.error)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Spacer()
                Button(role: .destructive) {
                    isShowingClearCartAlert = true
                } label: {
                    Label("Warenkorb leeren", systemImage: "trash")
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .semibold))
                }
                .tint(AppTheme.Colors.error)
                .disabled(cartManager.state.isLoading || cartManager.state.updatingItemKey != nil)
            }
            .padding(.bottom, AppTheme.Layout.Spacing.xSmall)
            
            HStack {
                Text("Gesamt")
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .bold))
                Spacer()
                Text(PriceFormatter.formatPriceFromMinorUnit(
                    value: totals.total_price ?? "0",
                    minorUnit: totals.currency_minor_unit ?? 2
                ))
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.headline, weight: .bold))
            }
            .padding(.top, AppTheme.Layout.Spacing.xSmall)

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
