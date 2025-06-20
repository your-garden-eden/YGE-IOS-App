//
//  ViewState.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 20.06.25.
//


// DATEI: ViewModelStateEnums.swift
// PFAD: Enums/ViewModelStateEnums.swift
// ZWECK: Stellt wiederverwendbare Enums für die Zustandsverwaltung in ViewModels bereit.

import Foundation

/// Definiert die möglichen Zustände für eine View, die dynamische Inhalte lädt.
public enum ViewState: Equatable {
    case loading
    case showSubCategories
    case showProducts
    case error(String)
    case empty
}

/// Definiert den primären Kontext für das Laden von Produkten in einer Produktliste.
public enum ProductListContext: Equatable {
    case categoryId(Int)
    case onSale, featured, byIds([Int]), search(String)
}
