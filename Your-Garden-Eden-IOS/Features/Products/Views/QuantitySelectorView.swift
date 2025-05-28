// Datei: QuantitySelectorView.swift
// Pfad: Your-Garden-Eden-IOS/Features/Products/Views/QuantitySelectorView.swift

import SwiftUI

struct QuantitySelectorView: View {
    @Binding var quantity: Int

    var body: some View {
        HStack(spacing: AppStyles.Spacing.medium) { // Etwas mehr Abstand zwischen Elementen
            Text("Menge:")
                .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .medium)) // AppFonts verwenden
                .foregroundColor(AppColors.textHeadings)

            Spacer()

            Button {
                if quantity > 1 { quantity -= 1 }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2) // Etwas größere Icons
                    .foregroundColor(quantity > 1 ? AppColors.primaryDark : AppColors.textMuted.opacity(0.5))
            }
            .disabled(quantity <= 1)

            Text("\(quantity)")
                .font(AppFonts.roboto(size: AppFonts.Size.title2, weight: .semibold)) // AppFonts verwenden
                .foregroundColor(AppColors.textBase)
                .frame(minWidth: 40, alignment: .center) // Mindestbreite für die Zahl

            Button {
                quantity += 1
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2) // Etwas größere Icons
                    .foregroundColor(AppColors.primaryDark) // AppColors verwenden
            }
        }
        .padding(.vertical, AppStyles.Spacing.small) // Vertikales Padding für die ganze HStack
        .buttonStyle(.plain) // Verhindert Standard-Button-Styling, das mit den Icons kollidieren könnte
    }
}

struct QuantitySelectorView_Previews: PreviewProvider {
    struct PreviewWrapper: View { // Wrapper für @State
        @State private var quantity = 1
        var body: some View {
            QuantitySelectorView(quantity: $quantity)
                .padding()
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
