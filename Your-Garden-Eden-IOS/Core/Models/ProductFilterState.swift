// DATEI: ProductFilterState.swift
// PFAD: Features/Products/Models/ProductFilterState.swift
// ZWECK: Modelliert den gesamten Zustand für die Filter- und Sortier-UI der Produktliste.
//        Diese Klasse wird vom ProductListViewModel gehalten und an die FilterView übergeben.

import SwiftUI

@MainActor
class ProductFilterState: ObservableObject {

    // MARK: - Sortierung
    enum SortOption: String, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case newest = "Neuheiten"
        case popularity = "Beliebtheit"
        case priceLowToHigh = "Preis: Aufsteigend"
        case priceHighToLow = "Preis: Absteigend"
        
        var apiValue: (orderBy: String, order: String) {
            switch self {
            case .newest: return ("date", "desc")
            case .popularity: return ("popularity", "desc")
            case .priceLowToHigh: return ("price", "asc")
            case .priceHighToLow: return ("price", "desc")
            }
        }
    }
    @Published var selectedSortOption: SortOption = .newest

    // MARK: - Preisspanne
    let absolutePriceRange: ClosedRange<Double> = 0...2000
    @Published var minPrice: Double
    @Published var maxPrice: Double

    // MARK: - Anzeige-Optionen
    @Published var showOnlyAvailable: Bool = true
    
    enum ProductTypeOption: String, CaseIterable, Identifiable {
        var id: String { self.rawValue }
        case all = "Alle Produkte"
        case simple = "Einzelprodukte"
        case variable = "Produkte mit Optionen"
    }
    @Published var selectedProductType: ProductTypeOption = .all

    // MARK: - Attribute (derzeit nicht implementiert in der UI)
    // Die Struktur ist für zukünftige Erweiterungen vorbereitet.
    
    /// Prüft, ob der Filter im unberührten Standardzustand ist.
    var isPristine: Bool {
        selectedSortOption == .newest &&
        minPrice == absolutePriceRange.lowerBound &&
        maxPrice == absolutePriceRange.upperBound &&
        showOnlyAvailable == true &&
        selectedProductType == .all
    }

    // MARK: - Initialisierung & Methoden
    init() {
        self.minPrice = absolutePriceRange.lowerBound
        self.maxPrice = absolutePriceRange.upperBound
    }

    /// Setzt alle Filter auf ihre Standardwerte zurück.
    func reset() {
        selectedSortOption = .newest
        minPrice = absolutePriceRange.lowerBound
        maxPrice = absolutePriceRange.upperBound
        showOnlyAvailable = true
        selectedProductType = .all
    }
}
