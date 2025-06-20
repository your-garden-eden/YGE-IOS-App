// DATEI: CartView.swift
// PFAD: Features/Cart/Views/CartView.swift
// VERSION: GUTSCHEIN 1.0
// ÄNDERUNG: Die 'cartTotalsView' wurde umfassend überarbeitet, um die Gutschein-UI zu integrieren.

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    @Environment(\.selectedTab) private var selectedTab
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var showingAuthSheet = false
    @State private var isShowingClearCartAlert = false
    @State private var couponCode: String = ""

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
                    let parentProductId = cartManager.state.variationToParentMap[item.id] ?? item.id
                    
                    if let product = cartManager.state.productDetails[parentProductId] {
                        NavigationLink(value: product) {
                            CartRowView(item: item)
                        }
                        .buttonStyle(.plain)
                    } else {
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
    
    // === BEGINN MODIFIKATION ===
    // UMFASSEND ÜBERARBEITET: cartTotalsView wurde für Gutscheinfunktionalität ertüchtigt.
    private func cartTotalsView(totals: Totals) -> some View {
        VStack(spacing: AppTheme.Layout.Spacing.small) {
            // Fehlermeldung
            if let error = cartManager.state.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.error)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, AppTheme.Layout.Spacing.xSmall)
            }
            
            // "Warenkorb leeren" Button
            HStack {
                Spacer()
                Button(role: .destructive) { isShowingClearCartAlert = true } label: {
                    Label("Warenkorb leeren", systemImage: "trash")
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .semibold))
                }
                .tint(AppTheme.Colors.error)
                .disabled(cartManager.state.isLoading)
            }
            .padding(.bottom, AppTheme.Layout.Spacing.xSmall)

            // NEU: Angewendete Gutscheine und Rabattanzeige
            if !(cartManager.state.coupons.isEmpty) || (totals.total_discount != nil && totals.total_discount != "0") {
                VStack(spacing: AppTheme.Layout.Spacing.xSmall) {
                    ForEach(cartManager.state.coupons) { coupon in
                        HStack {
                            Text("Gutschein \"\(coupon.code)\"")
                                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .regular))
                            
                            Button(action: {
                                Task { await cartManager.removeCoupon(code: coupon.code) }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.Colors.textMuted)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    if let discount = totals.total_discount, discount != "0" {
                         HStack {
                            Text("Rabatt")
                                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body, weight: .medium))
                            Spacer()
                            Text("- \(PriceFormatter.formatPriceFromMinorUnit(value: discount, minorUnit: totals.currency_minor_unit ?? 2))")
                                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .bold))
                                .foregroundColor(AppTheme.Colors.error)
                        }
                    }
                }
                .padding(.vertical, AppTheme.Layout.Spacing.small)
                
                Divider()
            }
            
            // Gesamtpreis
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
            
            // NEU: Gutschein-Eingabefeld
            HStack(spacing: AppTheme.Layout.Spacing.xSmall) {
                TextField("Gutscheincode eingeben...", text: $couponCode)
                    .textFieldStyle(AppTheme.PlainTextFieldStyle())
                    .disabled(cartManager.state.isLoading)
                
                Button("Anwenden") {
                    Task {
                        await cartManager.applyCoupon(code: couponCode)
                        couponCode = "" // Feld nach Versuch leeren
                    }
                }
                .buttonStyle(AppTheme.SecondaryButtonStyle())
                .disabled(couponCode.isEmpty || cartManager.state.isLoading)
            }
            .padding(.vertical, AppTheme.Layout.Spacing.small)

            // "Zur Kasse" Button
            NavigationLink(value: AppDestination.checkout) {
                 Text("Zur Kasse")
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(cartManager.state.items.isEmpty || cartManager.state.isLoading)
        }
        .padding()
        .background(.regularMaterial)
        .animation(.default, value: cartManager.state.coupons)
        .animation(.default, value: cartManager.state.totals)
    }
    // === ENDE MODIFIKATION ===
}
