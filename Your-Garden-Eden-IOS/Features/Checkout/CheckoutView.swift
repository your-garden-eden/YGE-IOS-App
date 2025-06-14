// Path: Your-Garden-Eden-IOS/Features/Checkout/CheckoutView.swift

import SwiftUI

struct CheckoutView: View, Hashable {
    
    // Hashable Konformität
    func hash(into hasher: inout Hasher) {
        hasher.combine("CheckoutViewIdentifier")
    }
    static func == (lhs: CheckoutView, rhs: CheckoutView) -> Bool {
        return true
    }
    
    var body: some View {
        ZStack {
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
    }
}
