//
//  CustomBackButtonModifier.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 16.06.25.
//


// Path: Your-Garden-Eden-IOS/Core/UI/ViewModifiers/CustomBackButtonModifier.swift
// VERSION 1.0 (FINAL)

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
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(AppColors.primary) // Verwenden Sie hier Ihre App-Farbe
                    }
                }
            }
    }
}

extension View {
    func customBackButton() -> some View {
        self.modifier(CustomBackButtonModifier())
    }
}