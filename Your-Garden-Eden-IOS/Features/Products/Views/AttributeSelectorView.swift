import SwiftUI

struct AttributeSelectorView: View {
    // Akzeptiert jetzt die neue, reichhaltigere Datenstruktur
    let attribute: DisplayableAttribute
    
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
            .font(.headline.weight(.semibold))
            .foregroundColor(AppColors.textHeadings)
            .padding(.leading, 4)
    }

    private var optionsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppStyles.Spacing.small) {
                // Iteriert jetzt über `DisplayableOption`-Objekte
                ForEach(attribute.options) { option in
                    let isSelected = currentlySelectedOptionSlugForThisAttribute == option.slug
                    let isDisabled = !availableOptionSlugs.contains(option.slug)
                    
                    Button(action: {
                        // Gibt den ECHTEN Slug an das ViewModel zurück
                        onOptionSelect(option.slug)
                    }) {
                        // Verwendet option.name für die Anzeige
                        optionButtonLabel(optionName: option.name, isSelected: isSelected)
                    }
                    .disabled(isDisabled)
                    .opacity(isDisabled ? 0.4 : 1.0)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func optionButtonLabel(optionName: String, isSelected: Bool) -> some View {
        Text(optionName)
            .font(.footnote.weight(isSelected ? .bold : .regular))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).fill(AppColors.primary)
                    } else {
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium).fill(AppColors.backgroundLightGray)
                    }
                    RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                        .stroke(isSelected ? AppColors.primaryDark : AppColors.borderLight, lineWidth: 1)
                }
            )
            .foregroundColor(isSelected ? AppColors.textOnPrimary : AppColors.textBase)
    }
}

// Die `toSlug()`-Erweiterung wird nicht mehr benötigt und kann gelöscht werden.
