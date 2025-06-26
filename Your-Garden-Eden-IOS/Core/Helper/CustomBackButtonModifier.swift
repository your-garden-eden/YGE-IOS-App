// DATEI: CustomBackButtonModifier.swift
// PFAD: Core/UI/Modifiers/CustomBackButtonModifier.swift
// VERSION: 1.0 (FINAL)
// STATUS: Stabil und einsatzbereit.

import SwiftUI

struct CustomBackButtonModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Zurück")
                                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.headline))
                        }
                        .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
    }
}

public extension View {
    func customBackButton() -> some View {
        self.modifier(CustomBackButtonModifier())
    }
}
