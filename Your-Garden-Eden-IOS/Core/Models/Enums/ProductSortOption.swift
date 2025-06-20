//
//  ProductSortOption.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 20.06.25.
//


// DATEI: ProductFilterEnums.swift
// PFAD: Enums/ProductFilterEnums.swift
// ZWECK: Zentralisiert alle Enums, die den Zustand der Produktfilterung und -sortierung definieren.

import Foundation

/// Definiert die verfügbaren Sortieroptionen für Produktlisten.
public enum ProductSortOption: String, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
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

/// Definiert die Optionen zur Filterung nach Produkttyp.
public enum ProductTypeFilterOption: String, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
    case all = "Alle Produkte"
    case simple = "Einzelprodukte"
    case variable = "Produkte mit Optionen"
    
    var apiValue: String? {
        switch self {
        case .all: return nil
        case .simple: return "simple"
        case .variable: return "variable"
        }
    }
}

/// Definiert den Ladezustand für die dynamisch abgerufenen Filter-Attribute.
public enum AttributeLoadingState: Equatable {
    case idle
    case loading
    case success
    case failed(Error)
    
    public static func == (lhs: AttributeLoadingState, rhs: AttributeLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.failed, .failed): return true
        default: return false
        }
    }
}
