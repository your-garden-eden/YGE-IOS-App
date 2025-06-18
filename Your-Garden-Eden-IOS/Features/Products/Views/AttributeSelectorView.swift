// DATEI: AttributeSelectorView.swift
// PFAD: Features/Products/Views/Options/AttributeSelectorView.swift
// ZWECK: Eine spezialisierte View zur Auswahl einer einzelnen Produkt-Option
//        (z.B. Farbe oder Größe). Sie ist eine Unterkomponente von ProductOptionsView.

import SwiftUI

struct AttributeSelectorView: View {
    
    let attribute: ProductOptionsViewModel.DisplayableAttribute
    let availableOptionSlugs: Set<String>
    let selectedOptionSlug: String?
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Layout.Spacing.small) {
            Text(attribute.name)
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(attribute.options) { option in
                        let isSelected = (selectedOptionSlug == option.slug)
                        let isAvailable = availableOptionSlugs.contains(option.slug) || isSelected
                        
                        Button(action: {
                            onSelect(option.slug)
                        }) {
                            Text(option.name)
                                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.backgroundLightGray)
                                .foregroundColor(isSelected ? .white : (isAvailable ? AppTheme.Colors.primary : AppTheme.Colors.textMuted))
                                .cornerRadius(AppTheme.Layout.BorderRadius.large)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Layout.BorderRadius.large)
                                        .stroke(isAvailable ? AppTheme.Colors.primary : AppTheme.Colors.textMuted, lineWidth: isSelected ? 0 : 1)
                                )
                                .overlay(
                                    // Visueller Indikator für eine nicht verfügbare Option
                                    Rectangle()
                                        .frame(height: 1.5)
                                        .foregroundColor(AppTheme.Colors.error.opacity(0.8))
                                        .rotationEffect(Angle(degrees: -10))
                                        .padding(.horizontal, -4)
                                        .opacity(isAvailable ? 0 : 1)
                                )
                        }
                        .disabled(!isAvailable)
                        .animation(.easeInOut(duration: 0.2), value: isAvailable)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                    }
                }
                .padding(.bottom, 4)
            }
        }
    }
}
