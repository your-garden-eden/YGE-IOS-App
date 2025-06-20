// DATEI: FilterView.swift
// PFAD: Views/FilterView.swift
// VERSION: FINAL - Alle Operationen integriert.

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
                attributesSection
            }
            .navigationTitle("Filter & Sortierung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurücksetzen") {
                        filterState.reset()
                    }
                    .tint(AppTheme.Colors.error)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Anwenden") {
                        onApply()
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.Colors.primary)
                }
            }
            .onAppear {
                Task {
                    await filterState.loadAvailableAttributes()
                }
            }
        }
    }
    
    private var sortSection: some View {
        Section(header: Text("Sortieren nach")) {
            Picker("Sortierung", selection: $filterState.selectedSortOption) {
                ForEach(ProductSortOption.allCases) { option in
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
                .tint(AppTheme.Colors.primary)
            
            Picker("Produkttyp", selection: $filterState.selectedProductType) {
                ForEach(ProductTypeFilterOption.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
        }
    }
    
    private var priceSection: some View {
        Section(header: Text("Preisspanne")) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Von \(Int(filterState.minPrice))€ bis \(Int(filterState.maxPrice))€")
                    .foregroundColor(AppTheme.Colors.textBase)
                
                HStack {
                    Text("Min:")
                    Slider(value: $filterState.minPrice, in: filterState.absolutePriceRange, step: 10)
                        .tint(AppTheme.Colors.primary)
                }
                
                HStack {
                    Text("Max:")
                    Slider(value: $filterState.maxPrice, in: filterState.absolutePriceRange, step: 10)
                        .tint(AppTheme.Colors.primary)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var attributesSection: some View {
        switch filterState.attributeLoadingState {
        case .loading:
            Section { HStack { Spacer(); ProgressView("Lade Optionen..."); Spacer() } }
        case .success:
            if filterState.availableAttributes.isEmpty {
                Section(header: Text("Optionen")) {
                    Text("Keine Filteroptionen verfügbar.").foregroundColor(.secondary)
                }
            } else {
                ForEach(filterState.availableAttributes) { attribute in
                    Section(header: Text(attribute.definition.name)) {
                        ForEach(attribute.terms) { term in
                            Button(action: {
                                filterState.toggleSelection(forAttributeSlug: attribute.definition.slug, termSlug: term.slug)
                            }) {
                                HStack {
                                    Text(term.name)
                                    Spacer()
                                    if filterState.isTermSelected(forAttributeSlug: attribute.definition.slug, termSlug: term.slug) {
                                        Image(systemName: "checkmark").foregroundColor(AppTheme.Colors.primary)
                                    }
                                }
                                .foregroundColor(AppTheme.Colors.textBase)
                            }
                        }
                    }
                }
            }
        case .failed(let error):
            Section(header: Text("Optionen")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fehler beim Laden").foregroundColor(AppTheme.Colors.error)
                    Text(error.localizedDescription).font(.caption).foregroundColor(.secondary)
                    Button("Erneut versuchen") { Task { await filterState.loadAvailableAttributes() } }.tint(AppTheme.Colors.primary)
                }
                .padding(.vertical, 4)
            }
        case .idle:
            EmptyView()
        }
    }
}
