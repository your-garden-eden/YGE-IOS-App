//
//  StockStatus.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: StockStatus.swift
// PFAD: Models/StockStatus.swift
// ZWECK: Definiert den Lagerstatus für Produkte. Isoliert in eigener Akte für weitreichende Verfügbarkeit.

import Foundation

/// Definiert den Lagerstatus eines Produkts.
/// Als `public` deklariert, um aus allen Modulen und Sektoren der App zugänglich zu sein.
public enum StockStatus: String, Codable, Hashable {
    /// Das Produkt ist auf Lager.
    case instock
    
    /// Das Produkt ist ausverkauft.
    case outofstock
    
    /// Das Produkt ist im Rückstand und kann nachbestellt werden.
    case onbackorder
}