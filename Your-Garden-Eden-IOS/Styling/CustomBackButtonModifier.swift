// DATEI: CustomBackButtonModifier.swift
// PFAD: Core/Navigation/AppNavigationModifier.swift
// VERSION: 2.0 (OPERATION: RÜCKZUG)

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
                            // ===================================================================
                            // **MODIFIKATION: TEXT AUF "ZURÜCK" GEÄNDERT**
                            // ===================================================================
                            Text("Zurück")
                                .font(.system(size: 17))
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
