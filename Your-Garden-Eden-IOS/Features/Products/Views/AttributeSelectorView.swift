// Datei: AttributeSelectorView.swift
// Pfad: Your-Garden-Eden-IOS/Features/Products/Views/AttributeSelectorView.swift

import SwiftUI

struct AttributeSelectorView: View {
    let attribute: WooCommerceAttribute
    let allProductVariations: [WooCommerceProductVariation]
    let currentlySelectedOptionSlugForThisAttribute: String?
    let onOptionSelect: (String) -> Void

    @State private var calculatedOptions: [(displayName: String, slug: String)] = []
    
    @ViewBuilder
    private func optionButtonLabel(option: (displayName: String, slug: String), isSelected: Bool) -> some View {
        Text(option.displayName)
            .font(AppFonts.roboto(size: AppFonts.Size.smallBody, weight: isSelected ? .bold : .regular))
            .padding(.horizontal, AppStyles.Spacing.medium)
            .padding(.vertical, AppStyles.Spacing.small)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                            .fill(AppColors.primary)
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                            .stroke(AppColors.primaryDark, lineWidth: 1.5)
                    } else {
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                            .fill(AppColors.backgroundLightGray)
                        RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium)
                            .stroke(AppColors.borderLight, lineWidth: 1)
                    }
                }
            )
            .foregroundColor(isSelected ? AppColors.textOnPrimary : AppColors.textBase)
            .clipShape(RoundedRectangle(cornerRadius: AppStyles.BorderRadius.medium))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
            if !calculatedOptions.isEmpty {
                Text("\(attribute.name):")
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                    .foregroundColor(AppColors.textHeadings)
                    .padding(.leading, AppStyles.Spacing.xxSmall)

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
        }
        .padding(.vertical, AppStyles.Spacing.small)
        .onAppear {
            updateCalculatedOptions()
        }
        .onChange(of: allProductVariations) {
            updateCalculatedOptions()
        }
        .onChange(of: attribute) { // Beobachte auch Änderungen am Attribut selbst
            updateCalculatedOptions()
        }
    }

    private func updateCalculatedOptions() {
        print("AttributeSelectorView: Updating calculated options for attribute '\(attribute.name)'")
        var uniqueOptions = [String: String]() // Key: Slug, Value: DisplayName

        for variation in allProductVariations {
            // Finde das Attribut in der aktuellen Variation, das zur Definition passt
            // (basierend auf ID, Name oder dem Slug der Attribut-Definition)
            if let variationAttribute = variation.attributes.first(where: { varAttr in
                (attribute.id != 0 && varAttr.id != 0 && varAttr.id == attribute.id) || // Vergleiche ID, wenn vorhanden
                varAttr.name == attribute.name || // Vergleiche Name
                (varAttr.slug != nil && varAttr.slug == attribute.slugOrNameAsSlug()) // Vergleiche Slug (pa_farbe)
            }) {
                let optionDisplayName = variationAttribute.option
                // Erzeuge Slug aus DisplayName der Option, wenn kein Slug im VariationAttribute vorhanden ist
                // WooCommerceProductVariation.VariationAttribute hat oft keinen Slug für die Option selbst,
                // daher generieren wir ihn konsistent.
                let optionSlug = variationAttribute.optionAsSlug() // Nutze die Extension
                
                if uniqueOptions[optionSlug] == nil {
                    uniqueOptions[optionSlug] = optionDisplayName
                }
            }
        }
        
        // Die Zuweisung zu @State-Variablen sollte auf dem Main-Thread erfolgen,
        // was hier durch @MainActor der View implizit gegeben sein sollte.
        // Sortiere die Optionen alphabetisch nach ihrem Anzeigenamen.
        self.calculatedOptions = uniqueOptions.map { (displayName: $0.value, slug: $0.key) }.sorted { $0.displayName < $1.displayName }
        print("AttributeSelectorView: Updated options for '\(attribute.name)': \(self.calculatedOptions.map { "\($0.displayName) (\($0.slug))" })")
    }
}

// KEIN PreviewProvider hier, um Mock-Daten-Fehler zu vermeiden
// struct AttributeSelectorView_Previews: PreviewProvider { ... }
