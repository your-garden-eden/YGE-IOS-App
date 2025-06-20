//
//  WishlistSortOption.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 20.06.25.
//


// DATEI: WishlistSortOption.swift
// PFAD: Enums/WishlistSortOption.swift
// ZWECK: Definiert die Sortieroptionen für die Wunschlisten-Ansicht.

import Foundation

public enum WishlistSortOption: String, CaseIterable, Identifiable {
    case dateAdded = "Neueste zuerst"
    case priceAscending = "Preis: aufsteigend"
    case priceDescending = "Preis: absteigend"
    case nameAscending = "Name: A-Z"
    
    public var id: String { self.rawValue }
}
