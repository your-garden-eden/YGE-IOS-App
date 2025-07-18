// DATEI: CartView.swift
// PFAD: Features/Cart/Views/CartView.swift
// VERSION: 2.2 (ANGEPASST)
// STATUS: Fehlende View-Implementierung hinzugefügt und Referenz korrigiert.

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    @Environment(\.selectedTab) private var selectedTab
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var showingAuthSheet = false
    @State private var isShowingClearCartAlert = false
    @State private var couponCode: String = ""
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AppTheme.Colors.backgroundPage.ignoresSafeArea()
                if cartManager.state.isLoading && cartManager.state.items.isEmpty { initialLoadingView }
                else if cartManager.state.items.isEmpty { emptyCartView }
                // KORREKTUR: Falsche Referenz 'ContentView' zu 'cartContentView' geändert.
                else { cartContentView }
            }
            .withAppNavigation()
            .navigationBarTitleDisplayMode(.inline)
            .refreshable { await cartManager.getCart() }
            .sheet(isPresented: $showingAuthSheet) { AuthContainerView(onDismiss: { self.showingAuthSheet = false }) }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { selectedTab.wrappedValue = 1 }) {
                        HStack { Image(systemName: "arrow.left"); Text("Zum Shop") }.foregroundColor(AppTheme.Colors.primaryDark)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Image("logo_your_garden_eden_transparent").resizable().scaledToFit().frame(height: 150)
                }
            }
            .navigationBarBackButtonHidden(true)
            .alert("Warenkorb leeren?", isPresented: $isShowingClearCartAlert) {
                Button("Löschen", role: .destructive) { Task { await cartManager.clearCart() } }
                Button("Abbrechen", role: .cancel) { }
            } message: { Text("Möchten Sie wirklich alle Artikel entfernen?") }
        }
    }
    
    // ===================================================================
    // === BEGINN KORREKTUR #6.2                                       ===
    // ===================================================================
    // HINZUGEFÜGT: Fehlende View-Implementierung.
    private var cartContentView: some View {
        List {
            ForEach(cartManager.state.items) { item in
                CartRowView(item: item, path: $path)
            }
            .onDelete(perform: deleteItems)
            .listRowBackground(AppTheme.Colors.backgroundPage)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal)
        .safeAreaInset(edge: .bottom) {
            if let totals = cartManager.state.totals {
                cartTotalsView(totals: totals)
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        guard cartManager.state.updatingItemKey == nil else { return }
        offsets.map { cartManager.state.items[$0].key }.forEach { key in
            Task { await cartManager.removeItem(key: key) }
        }
    }
    
    private func cartTotalsView(totals: Totals) -> some View {
        VStack(spacing: 8) {
            if let error = cartManager.state.errorMessage {
                Text(error).font(.caption).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).padding(.bottom, 4)
            }
            HStack {
                Spacer()
                Button(role: .destructive) { isShowingClearCartAlert = true } label: { Label("Warenkorb leeren", systemImage: "trash").font(.caption.weight(.semibold)) }.tint(.red).disabled(cartManager.state.isLoading)
            }.padding(.bottom, 4)
            
            if !cartManager.state.coupons.isEmpty || !(totals.total_discount ?? "0").hasPrefix("0") {
                VStack(spacing: 4) {
                    ForEach(cartManager.state.coupons) { coupon in
                        HStack {
                            Text("Gutschein \"\(coupon.code.uppercased())\"").font(.body)
                            Button(action: { Task { await cartManager.removeCoupon(code: coupon.code) } }) { Image(systemName: "xmark.circle.fill").foregroundColor(.secondary) }
                            Spacer()
                        }
                    }
                    if let discount = totals.total_discount, discount != "0" {
                         HStack {
                            Text("Rabatt").font(.body.weight(.medium))
                            Spacer()
                            Text("- \(PriceFormatter.formatPriceFromMinorUnit(value: discount, minorUnit: totals.currency_minor_unit ?? AppConfig.defaultCurrencyMinorUnit))").font(.body.weight(.bold)).foregroundColor(.red)
                        }
                    }
                }.padding(.vertical, 8).animation(.default, value: cartManager.state.coupons)
                Divider()
            }
            
            HStack {
                Text("Gesamt").font(.headline.weight(.bold))
                Spacer()
                Text(PriceFormatter.formatPriceFromMinorUnit(value: totals.total_price, minorUnit: totals.currency_minor_unit ?? AppConfig.defaultCurrencyMinorUnit)).font(.headline.weight(.bold))
            }.padding(.top, 4)
            
            HStack(spacing: 4) {
                TextField("Gutscheincode...", text: $couponCode).textFieldStyle(AppTheme.PlainTextFieldStyle()).disabled(cartManager.state.isLoading)
                Button("Anwenden") { Task { await cartManager.applyCoupon(code: couponCode); couponCode = "" } }.buttonStyle(AppTheme.SecondaryButtonStyle()).disabled(couponCode.isEmpty || cartManager.state.isLoading)
            }.padding(.vertical, 8)
            
            NavigationLink(value: AppDestination.checkout) { Text("Zur Kasse") }.buttonStyle(AppTheme.PrimaryButtonStyle()).disabled(cartManager.state.items.isEmpty || cartManager.state.isLoading)
        }
        .padding()
        .background(.regularMaterial)
        .animation(.default, value: cartManager.state.totals)
    }
    // ===================================================================
    // === ENDE KORREKTUR #6.2                                         ===
    // ===================================================================

    private var initialLoadingView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            ProgressView().tint(AppTheme.Colors.primary)
            Text("Lade Warenkorb...").foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            if authManager.isLoggedIn {
                Image(systemName: "cart").font(.system(size: 60, weight: .light)).foregroundColor(.secondary)
                Text("Dein Warenkorb ist leer").font(AppTheme.Fonts.montserrat(size: 22, weight: .bold))
                Button("Weiter einkaufen") { self.selectedTab.wrappedValue = 1 }.buttonStyle(AppTheme.PrimaryButtonStyle()).padding(.top)
            } else {
                Image(systemName: "person.crop.circle.badge.questionmark.fill").font(.system(size: 60)).foregroundColor(.secondary)
                Text("Anmelden für Warenkorb").font(AppTheme.Fonts.montserrat(size: 22, weight: .bold))
                Text("Melde dich an, um deinen Warenkorb geräteübergreifend zu speichern.").multilineTextAlignment(.center)
                Button("Anmelden / Registrieren") { self.showingAuthSheet = true }.buttonStyle(AppTheme.PrimaryButtonStyle()).padding(.top)
            }
        }.padding()
    }
}
