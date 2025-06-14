// Path: Your-Garden-Eden-IOS/Features/Products/Views/AttributeSelectorView.swift

import SwiftUI

struct AttributeSelectorView: View {
    let attribute: ProductOptionsViewModel.DisplayableAttribute
    let availableOptionSlugs: Set<String>
    let selectedOptionSlug: String?
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            Text(attribute.name)
                .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(attribute.options) { option in
                        let isSelected = (selectedOptionSlug == option.slug)
                        let isAvailable = availableOptionSlugs.contains(option.slug) || selectedOptionSlug != nil
                        
                        Button(action: {
                            onSelect(option.slug)
                        }) {
                            Text(option.name)
                                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(isSelected ? AppColors.primary : AppColors.backgroundLightGray)
                                .foregroundColor(isSelected ? .white : AppColors.primary)
                                .cornerRadius(AppStyles.BorderRadius.large)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppStyles.BorderRadius.large)
                                        .stroke(AppColors.primary, lineWidth: isSelected ? 0 : 1)
                                )
                                .overlay(
                                    Rectangle()
                                        .frame(width: nil, height: 1.5, alignment: .center)
                                        .foregroundColor(AppColors.error)
                                        .rotationEffect(Angle(degrees: -10))
                                        .padding(.horizontal, -4)
                                        .opacity(isAvailable ? 0 : 1)
                                )
                        }
                        .disabled(!isAvailable)
                        .opacity(isAvailable ? 1.0 : 0.4)
                    }
                }
            }
        }
    }
}
