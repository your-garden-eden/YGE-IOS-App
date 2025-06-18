// DATEI: CheckoutView.swift
// PFAD: Features/Checkout/Views/CheckoutView.swift
// VERSION: 1.1 (FINAL & ANGEPASST)

import SwiftUI

struct CheckoutView: View {
    
    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            
            VStack(spacing: AppTheme.Layout.Spacing.large) {
                
                Image(systemName: "creditcard.and.123")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("Kasse")
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textHeadings)
                
                Text("Dieser Bereich ist in Entwicklung.\nHier wird der Bezahlvorgang implementiert.")
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                    .foregroundColor(AppTheme.Colors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Kasse")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton() // <-- BEFEHL HINZUGEFÜGT
    }
}
