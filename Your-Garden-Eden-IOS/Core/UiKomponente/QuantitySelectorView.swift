//
//  QuantitySelectorView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: QuantitySelectorView.swift
// PFAD: Core/UI/Components/QuantitySelectorView.swift
// ZWECK: Eine wiederverwendbare View zur Auswahl einer Menge (z.B. im Warenkorb oder auf der Produktdetailseite).

import SwiftUI

public struct QuantitySelectorView: View {
    @Binding var quantity: Int

    public var body: some View {
        HStack(spacing: AppTheme.Layout.Spacing.medium) {
            Text("Menge:")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.headline, weight: .medium))
                .foregroundColor(AppTheme.Colors.textHeadings)

            Spacer()

            Button {
                if quantity > 1 { quantity -= 1 }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(quantity > 1 ? AppTheme.Colors.primaryDark : AppTheme.Colors.textMuted.opacity(0.5))
            }
            .disabled(quantity <= 1)

            Text("\(quantity)")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.title2, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textBase)
                .frame(minWidth: 40, alignment: .center)

            Button {
                quantity += 1
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.Colors.primaryDark)
            }
        }
        .padding(.vertical, AppTheme.Layout.Spacing.small)
        .buttonStyle(.plain)
    }
}