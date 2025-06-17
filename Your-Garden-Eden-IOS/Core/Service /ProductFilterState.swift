// Path: Your-Garden-Eden-IOS/Features/Products/Models/ProductFilterState.swift
// VERSION 1.1 (Dual Slider Logic)

import Foundation
import SwiftUI // Nötig für Binding

@MainActor
class ProductFilterState: ObservableObject {

    // MARK: - Sortierung
    enum SortOption: String, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case popularity = "Beliebtheit"
        case newest = "Neuheiten"
        case priceLowToHigh = "Preis: Aufsteigend"
        case priceHighToLow = "Preis: Absteigend"
    }

    @Published var selectedSortOption: SortOption = .popularity

    // MARK: - Preisspanne
    let absolutePriceRange: ClosedRange<Double> = 0...1000
    
    // NEUE LOGIK: Wir speichern min und max separat.
    @Published var minPrice: Double
    @Published var maxPrice: Double

    // Die `currentPriceRange` ist jetzt eine berechnete Eigenschaft.
    var currentPriceRange: ClosedRange<Double> {
        minPrice...maxPrice
    }

    // MARK: - Attribute (z.B. Farbe)
    struct FilterableAttribute: Identifiable {
        let id = UUID()
        let name: String
        let slug: String
        let options: [String]
    }
    
    @Published var availableAttributes: [FilterableAttribute] = [
        .init(name: "Farbe", slug: "pa_color", options: ["Grau", "Schwarz", "Braun", "Creme", "Weiß"]),
        .init(name: "Material", slug: "pa_material", options: ["Holz", "Metall", "Poly Rattan"])
    ]
    @Published var selectedAttributes: [String: Set<String>] = [:]

    // MARK: - Initializer & Methoden
    init() {
        self.minPrice = absolutePriceRange.lowerBound
        self.maxPrice = absolutePriceRange.upperBound
    }

    func reset() {
        selectedSortOption = .popularity
        minPrice = absolutePriceRange.lowerBound
        maxPrice = absolutePriceRange.upperBound
        selectedAttributes.removeAll()
    }
    
    func isOptionSelected(for attributeSlug: String, option: String) -> Bool {
        return selectedAttributes[attributeSlug]?.contains(option) ?? false
    }
    
    func toggleOptionSelection(for attributeSlug: String, option: String) {
        var aSet = selectedAttributes[attributeSlug] ?? Set<String>()
        if aSet.contains(option) {
            aSet.remove(option)
        } else {
            aSet.insert(option)
        }
        
        if aSet.isEmpty {
            selectedAttributes.removeValue(forKey: attributeSlug)
        } else {
            selectedAttributes[attributeSlug] = aSet
        }
    }
    
    // NEU: Hilfs-Bindings, um die Logik zu kapseln, dass min nicht über max gehen kann und umgekehrt.
    var minPriceBinding: Binding<Double> {
        Binding<Double>(
            get: { self.minPrice },
            set: { newMin in
                self.minPrice = min(newMin, self.maxPrice)
            }
        )
    }

    var maxPriceBinding: Binding<Double> {
        Binding<Double>(
            get: { self.maxPrice },
            set: { newMax in
                self.maxPrice = max(newMax, self.minPrice)
            }
        )
    }
}
