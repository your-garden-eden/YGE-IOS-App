//
//  AttributeSelectorView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import SwiftUI

struct AttributeSelectorView: View {
    // KORREKTUR: Verwendet jetzt die im ViewModel definierte Struktur.
    let attribute: ProductOptionsViewModel.DisplayableAttribute
    
    let availableOptionSlugs: Set<String>
    let currentlySelectedOptionSlugForThisAttribute: String?
    let onOptionSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            if !attribute.options.isEmpty {
                attributeTitle
                optionsScrollView
            }
        }
        .padding(.vertical, AppStyles.Spacing.small)
    }
    
    private var attributeTitle: some View {
        Text("\(attribute.name):")
            .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
            .foregroundColor(AppColors.textHeadings)
            .padding(.leading, 4)
    }

    private var optionsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppStyles.Spacing.small) {
                // KORREKTUR: Iteriert jetzt über die korrekten `Option`-Objekte.
                ForEach(attribute.options) { option in
                    let isSelected = currentlySelectedOptionSlugForThisAttribute == option.slug
                    let isDisabled = !availableOptionSlugs.contains(option.slug)
                    
                    Button(action: {
                        onOptionSelect(option.slug)
                    }) {
                        optionButtonLabel(optionName: option.name, isSelected: isSelected)
                    }
                    .disabled(isDisabled)
                    .opacity(isDisabled ? 0.4 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isDisabled)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func optionButtonLabel(optionName: String, isSelected: Bool) -> some View {
        Text(optionName)
            .font(AppFonts.roboto(size: AppFonts.Size.smallBody, weight: isSelected ? .bold : .regular))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).fill(AppColors.primary)
                    } else {
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).fill(AppColors.backgroundComponent)
                    }
                    RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                        .stroke(isSelected ? AppColors.primaryDark : AppColors.borderLight, lineWidth: 1.5)
                }
            )
            .foregroundColor(isSelected ? AppColors.textOnPrimary : AppColors.textBase)
    }
}
