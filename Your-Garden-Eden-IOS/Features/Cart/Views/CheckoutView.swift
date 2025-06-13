// Dateiname: Features/Checkout/CheckoutView.swift

import SwiftUI

// Die View muss 'Hashable' sein, damit der moderne NavigationStack sie als
// Ziel für einen NavigationLink verwenden kann.
struct CheckoutView: View, Hashable {
    
    // Hashable-Konformität, damit die Navigation funktioniert.
    // Da die View keine eigenen Properties hat, die ihren Zustand ändern,
    // können wir eine einfache Implementierung verwenden.
    func hash(into hasher: inout Hasher) {
        // Wir geben der View eine eindeutige Kennung für den Hash-Wert.
        hasher.combine("CheckoutViewIdentifier")
    }

    static func == (lhs: CheckoutView, rhs: CheckoutView) -> Bool {
        // Da es nur eine Art von CheckoutView ohne Parameter gibt,
        // sind zwei Instanzen immer gleich.
        return true
    }
    
    var body: some View {
        ZStack {
            // Hintergrundfarbe aus Ihrem Design-System
            AppColors.backgroundPage.ignoresSafeArea()
            
            VStack(spacing: AppStyles.Spacing.large) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)
                
                Text("Kasse")
                    .font(AppFonts.montserrat(size: AppFonts.Size.h2, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
                
                Text("Dieser Bereich ist in Entwicklung.\nHier kommt der Bezahlvorgang hin.")
                    .font(AppFonts.roboto(size: AppFonts.Size.body))
                    .foregroundColor(AppColors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Kasse")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Kasse")
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
            }
        }
    }
}

// MARK: - SwiftUI Preview
// Dieser Block ermöglicht es Ihnen, die View direkt im Xcode Canvas zu sehen.
#Preview {
    NavigationStack {
        CheckoutView()
    }
}
