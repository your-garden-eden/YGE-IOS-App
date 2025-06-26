// DATEI: CheckoutView.swift
// PFAD: Features/Cart/Views/CheckoutView.swift
// VERSION: 1.3 (REPARIERT)
// STATUS: Einsatzbereit.

import SwiftUI

struct CheckoutView: View {
    
    // HINWEIS: Es ist untypisch, den cartManager hier als @StateObject zu deklarieren,
    // da er üblicherweise als @EnvironmentObject übergeben wird.
    // Gemäß der Direktive, nur den gemeldeten Fehler zu beheben, belasse ich es dabei.
    @StateObject private var cartManager = CartAPIManager.shared
    @State private var checkoutURL: IdentifiableURL?
    
    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            
            if cartManager.state.items.isEmpty && !cartManager.state.isLoading {
                emptyCartView
            } else {
                checkoutContentView
            }
            
            if cartManager.state.isLoading {
                LoadingOverlayView()
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !cartManager.state.items.isEmpty {
                checkoutButton
            }
        }
        .fullScreenCover(item: $checkoutURL) { identifiableURL in
            SafariWebView(url: identifiableURL.url)
                .ignoresSafeArea()
        }
        .alert("Fehler", isPresented: .constant(cartManager.state.errorMessage != nil), actions: {
            Button("OK", role: .cancel) {
                cartManager.clearErrorMessage()
            }
        }, message: {
            Text(cartManager.state.errorMessage ?? "Ein unbekannter Fehler ist aufgetreten.")
        })
        .navigationTitle("Kasse")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
    }
    
    private var checkoutContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.large) {
                VStack {
                    Text("Bestellübersicht").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
                    Text("Bitte überprüfen Sie Ihre Artikel.").font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                }.foregroundColor(AppTheme.Colors.textHeadings).frame(maxWidth: .infinity).padding(.vertical)

                SectionView(title: "Ihre Artikel") {
                    ForEach(cartManager.state.items) { item in
                        // ===================================================================
                        // === BEGINN KORREKTUR #15                                        ===
                        // ===================================================================
                        // ANPASSUNG: Ein konstanter, leerer NavigationPath wird übergeben,
                        // um die Anforderung des CartRowView-Initializers zu erfüllen.
                        CartRowView(item: item, path: .constant(NavigationPath()))
                            .disabled(true) // Navigation im Checkout weiterhin deaktivieren
                        // ===================================================================
                        // === ENDE KORREKTUR #15                                          ===
                        // ===================================================================
                        if item.id != cartManager.state.items.last?.id { Divider() }
                    }
                }
                
                if let totals = cartManager.state.totals {
                    SectionView(title: "Gesamtsumme") {
                        PriceRow(label: "Zwischensumme", value: PriceFormatter.formatPriceFromMinorUnit(value: totals.total_items, minorUnit: totals.currency_minor_unit ?? 2))
                        PriceRow(label: "Rabatt", value: "- \(PriceFormatter.formatPriceFromMinorUnit(value: totals.total_discount, minorUnit: totals.currency_minor_unit ?? 2))", isVisible: !(totals.total_discount ?? "0").hasPrefix("0"))
                        PriceRow(label: "Versand", value: "Wird im nächsten Schritt berechnet")
                        Divider().padding(.vertical, 4)
                        PriceRow(label: "Gesamt (inkl. MwSt.)", value: PriceFormatter.formatPriceFromMinorUnit(value: totals.total_price, minorUnit: totals.currency_minor_unit ?? 2), isBold: true)
                    }
                }
                Spacer()
            }.padding()
        }
    }
    
    private var checkoutButton: some View {
        Button(action: { Task { self.checkoutURL = await cartManager.stageCartForCheckout() } }) {
            Text("Weiter zur Bezahlung")
        }
        .buttonStyle(AppTheme.PrimaryButtonStyle())
        .disabled(cartManager.state.items.isEmpty || cartManager.state.isLoading)
        .padding()
        .background(Material.regular)
    }
    
    private var emptyCartView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Image(systemName: "cart.badge.questionmark").font(.system(size: 60, weight: .light)).foregroundColor(AppTheme.Colors.textMuted)
            Text("Leerer Warenkorb").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
            Text("Sie haben noch keine Artikel im Warenkorb.").font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)).foregroundColor(AppTheme.Colors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h3, weight: .semibold))
            VStack { content }.padding()
                .background(AppTheme.Colors.backgroundComponent)
                .cornerRadius(AppTheme.Layout.BorderRadius.medium)
                .appShadow(AppTheme.Shadows.small)
        }
    }
}

struct PriceRow: View {
    let label: String
    let value: String?
    var isBold: Bool = false
    var isVisible: Bool = true
    
    var body: some View {
        if isVisible, let value = value {
            HStack {
                Text(label)
                Spacer()
                Text(value)
            }
            .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: isBold ? .bold : .regular))
            .foregroundColor(isBold ? AppTheme.Colors.textHeadings : AppTheme.Colors.textBase)
        }
    }
}
