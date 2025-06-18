// DATEI: ProductFilterParameters.swift
// PFAD: Features/Products/Models/ProductFilterParameters.swift
// VERSION: 2.0 (FINAL)
// ZWECK: Eine einfache Datenstruktur, die alle möglichen Filter- und Sortierparameter
//        für eine API-Anfrage an den Produkt-Endpunkt bündelt. Entkoppelt die
//        API-Schicht von der UI-Zustandsverwaltung (`ProductFilterState`).

import Foundation

struct ProductFilterParameters {
    // Kontext-Filter
    var categoryId: Int?
    var onSale: Bool?
    var featured: Bool?
    var searchQuery: String?
    var include: [Int]?
    
    // Attribut- & Preis-Filter
    var stockStatus: StockStatus?
    var productType: String?
    var minPrice: String?
    var maxPrice: String?
    
    // Sortierparameter
    var orderBy: String?
    var order: String?
}
