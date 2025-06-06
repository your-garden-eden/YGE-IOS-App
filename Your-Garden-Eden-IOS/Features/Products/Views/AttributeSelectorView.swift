import SwiftUI

struct AttributeSelectorView: View {
    let attribute: WooCommerceAttribute
    
    // NEU: Diese Menge enthält die Slugs der Optionen, die klickbar sein sollen.
    // Wird vom ViewModel berechnet.
    let availableOptionSlugs: Set<String>
    
    let currentlySelectedOptionSlugForThisAttribute: String?
    let onOptionSelect: (String) -> Void
    
    // HINWEIS: Die Eigenschaft `allProductVariations` wird nicht mehr benötigt,
    // da die Berechnungslogik nun vollständig im ViewModel liegt.
    
    private var options: [(displayName: String, slug: String)] {
        // Wir verwenden direkt die Optionen aus dem Attribut-Objekt.
        return attribute.options.map { (displayName: $0, slug: $0.toSlug()) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            if !options.isEmpty {
                attributeTitle
                optionsScrollView
            }
        }
        .padding(.vertical, AppStyles.Spacing.small)
    }
    
    private var attributeTitle: some View {
        Text("\(attribute.name):")
            .font(.headline.weight(.semibold)) // Angepasste Schriftart für bessere Lesbarkeit
            .foregroundColor(AppColors.textHeadings)
            .padding(.leading, 4)
    }

    private var optionsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppStyles.Spacing.small) {
                ForEach(options, id: \.slug) { option in
                    let isSelected = currentlySelectedOptionSlugForThisAttribute == option.slug
                    // NEU: Eine Option ist deaktiviert, wenn sie nicht in den `availableOptionSlugs`
                    // enthalten ist UND sie nicht die aktuell ausgewählte ist.
                    let isDisabled = !availableOptionSlugs.contains(option.slug) && !isSelected
                    
                    Button(action: {
                        onOptionSelect(option.slug)
                    }) {
                        optionButtonLabel(option: option, isSelected: isSelected)
                    }
                    .disabled(isDisabled)
                    .opacity(isDisabled ? 0.4 : 1.0) // Visuelles Feedback für deaktivierte Buttons
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func optionButtonLabel(option: (displayName: String, slug: String), isSelected: Bool) -> some View {
        Text(option.displayName)
            .font(.footnote.weight(isSelected ? .bold : .regular)) // Angepasste Schriftart
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

// Hilfsfunktion, um aus einem Optionsnamen einen Slug zu machen.
// Beispiel: "Dunkel Blau" -> "dunkel-blau"
extension String {
    func toSlug() -> String {
        let baseSlug = self.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
            
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        return baseSlug.components(separatedBy: allowedCharacters.inverted).joined()
    }
}
