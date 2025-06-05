import SwiftUI

struct AttributeSelectorView: View {
    let attribute: WooCommerceAttribute
    let allProductVariations: [WooCommerceProductVariation]
    let currentlySelectedOptionSlugForThisAttribute: String?
    let onOptionSelect: (String) -> Void

    @State private var calculatedOptions: [(displayName: String, slug: String)] = []
    
    // MARK: - Body (unverändert zur letzten Version)
    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            if !calculatedOptions.isEmpty {
                attributeTitle
                optionsScrollView
            }
        }
        .padding(.vertical, AppStyles.Spacing.small)
        .onAppear {
            updateCalculatedOptions()
        }
        .onChange(of: allProductVariations) {
            updateCalculatedOptions()
        }
        .onChange(of: attribute) {
            updateCalculatedOptions()
        }
    }
    
    // MARK: - Subviews (unverändert zur letzten Version)
    private var attributeTitle: some View {
        Text("\(attribute.name):")
            .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
            .foregroundColor(AppColors.textHeadings)
            .padding(.leading, AppStyles.Spacing.xxSmall)
    }

    private var optionsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppStyles.Spacing.small) {
                ForEach(calculatedOptions, id: \.slug) { option in
                    Button(action: {
                        onOptionSelect(option.slug)
                    }) {
                        optionButtonLabel(
                            option: option,
                            isSelected: currentlySelectedOptionSlugForThisAttribute == option.slug
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppStyles.Spacing.xxSmall)
        }
    }

    @ViewBuilder
    private func optionButtonLabel(option: (displayName: String, slug: String), isSelected: Bool) -> some View {
        // ... (Dieser Teil bleibt unverändert)
        Text(option.displayName)
            .font(AppFonts.roboto(size: AppFonts.Size.smallBody, weight: isSelected ? .bold : .regular))
            .padding(.horizontal, AppStyles.Spacing.medium)
            .padding(.vertical, AppStyles.Spacing.small)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).fill(AppColors.primary)
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).stroke(AppColors.primaryDark, lineWidth: 1.5)
                    } else {
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).fill(AppColors.backgroundLightGray)
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).stroke(AppColors.borderLight, lineWidth: 1)
                    }
                }
            )
            .foregroundColor(isSelected ? AppColors.textOnPrimary : AppColors.textBase)
            .clipShape(RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium))
    }
    
    // MARK: - Logic (STARK VEREINFACHT)
    private func updateCalculatedOptions() {
        print("AttributeSelectorView: Updating options for '\(attribute.name)' using calculator.")
        
        // Rufe die ausgelagerte Logik auf
        let newOptions = AttributeOptionCalculator.calculate(
            for: attribute,
            from: allProductVariations
        )
        
        // Einfache Zuweisung
        self.calculatedOptions = newOptions
        
        print("AttributeSelectorView: Updated options: \(self.calculatedOptions.map { "\($0.displayName) (\($0.slug))" })")
    }
}
