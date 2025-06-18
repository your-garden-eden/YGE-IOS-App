import SwiftUI

struct FilterView: View {
    
    @ObservedObject var filterState: ProductFilterState
    @Binding var isPresented: Bool
    let onApply: () -> Void

    var body: some View {
        NavigationView {
            Form {
                sortSection
                optionsSection
                priceSection
                // attributesSection // Vorerst auskommentiert, da in ProductFilterState noch nicht voll implementiert.
            }
            .navigationTitle("Filter & Sortierung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurücksetzen") {
                        filterState.reset()
                    }
                    // KORREKTUR: Korrekter Zugriffspfad auf die Farb-Ressource.
                    .tint(AppTheme.Colors.error)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Anwenden") {
                        onApply()
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    // KORREKTUR: Korrekter Zugriffspfad auf die Farb-Ressource.
                    .tint(AppTheme.Colors.primary)
                }
            }
        }
    }
    
    private var sortSection: some View {
        Section(header: Text("Sortieren nach")) {
            Picker("Sortierung", selection: $filterState.selectedSortOption) {
                ForEach(ProductFilterState.SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }
    
    private var optionsSection: some View {
        Section(header: Text("Anzeige-Optionen")) {
            Toggle("Nur verfügbare Produkte", isOn: $filterState.showOnlyAvailable)
                // KORREKTUR: Korrekter Zugriffspfad auf die Farb-Ressource.
                .tint(AppTheme.Colors.primary)
            
            Picker("Produkttyp", selection: $filterState.selectedProductType) {
                ForEach(ProductFilterState.ProductTypeOption.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
        }
    }
    
    private var priceSection: some View {
        Section(header: Text("Preisspanne")) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Von \(Int(filterState.minPrice))€ bis \(Int(filterState.maxPrice))€")
                    // KORREKTUR: Korrekter Zugriffspfad auf die Farb-Ressource.
                    .foregroundColor(AppTheme.Colors.textBase)
                
                HStack {
                    Text("Min:")
                    // HINWEIS: Stellt sicher, dass ProductFilterState eine `minPriceBinding`-Property bereitstellt.
                    Slider(value: $filterState.minPrice, in: filterState.absolutePriceRange, step: 10)
                        // KORREKTUR: Korrekter Zugriffspfad auf die Farb-Ressource.
                        .tint(AppTheme.Colors.primary)
                }
                
                HStack {
                    Text("Max:")
                    // HINWEIS: Stellt sicher, dass ProductFilterState eine `maxPriceBinding`-Property bereitstellt.
                    Slider(value: $filterState.maxPrice, in: filterState.absolutePriceRange, step: 10)
                        // KORREKTUR: Korrekter Zugriffspfad auf die Farb-Ressource.
                        .tint(AppTheme.Colors.primary)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    /*
    // Diese Sektion ist vorbereitet für die Re-Aktivierung, sobald die Logik in ProductFilterState implementiert ist.
    private var attributesSection: some View {
        ForEach(filterState.availableAttributes) { attribute in
            Section(header: Text(attribute.name)) {
                ForEach(Array(attribute.options.sorted()), id: \.self) { option in
                    Button(action: {
                        filterState.toggleOptionSelection(for: attribute.name, option: option)
                    }) {
                        HStack {
                            Text(option)
                            Spacer()
                            if filterState.isOptionSelected(for: attribute.name, option: option) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                        .foregroundColor(AppTheme.Colors.textBase)
                    }
                }
            }
        }
    }
    */
}
