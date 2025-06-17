// Path: Your-Garden-Eden-IOS/Features/Products/Views/FilterView.swift
// VERSION 1.1 (Dual Slider UI)

import SwiftUI

struct FilterView: View {
    
    @StateObject var filterState: ProductFilterState
    @Binding var isPresented: Bool
    let onApply: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sortieren nach")) {
                    Picker("Sortierung", selection: $filterState.selectedSortOption) {
                        ForEach(ProductFilterState.SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                // ===================================================================
                // **KORREKTUR: Einzel-Slider durch zwei separate Slider ersetzt.**
                // ===================================================================
                Section(header: Text("Preisspanne")) {
                    VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                        // Zeigt die aktuelle Auswahl an
                        Text("Von \(Int(filterState.minPrice))€ bis \(Int(filterState.maxPrice))€")
                            .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .bold))
                            .foregroundColor(AppColors.primaryDark)
                        
                        // Slider für den Minimalpreis
                        HStack {
                            Text("Min:")
                            Slider(value: filterState.minPriceBinding, in: filterState.absolutePriceRange, step: 10)
                                .tint(AppColors.primary)
                        }
                        
                        // Slider für den Maximalpreis
                        HStack {
                            Text("Max:")
                            Slider(value: filterState.maxPriceBinding, in: filterState.absolutePriceRange, step: 10)
                                .tint(AppColors.primary)
                        }
                    }
                    .padding(.vertical, AppStyles.Spacing.small)
                }
                
                ForEach(filterState.availableAttributes) { attribute in
                    Section(header: Text(attribute.name)) {
                        ForEach(attribute.options, id: \.self) { option in
                            Button(action: {
                                filterState.toggleOptionSelection(for: attribute.slug, option: option)
                            }) {
                                HStack {
                                    Text(option)
                                    Spacer()
                                    if filterState.isOptionSelected(for: attribute.slug, option: option) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(AppColors.primary)
                                    }
                                }
                                .foregroundColor(AppColors.textBase)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter & Sortierung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurücksetzen") {
                        filterState.reset()
                    }
                    .tint(AppColors.error)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Anwenden") {
                        onApply()
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primary)
                }
            }
        }
    }
}
