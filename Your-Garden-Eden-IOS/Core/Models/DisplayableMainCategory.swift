// Path: Your-Garden-Eden-IOS/Core/Models/SharedDisplayModels.swift

import Foundation

// Modelle, die Daten für die UI aufbereiten und übergeben.

struct DisplayableMainCategory: Identifiable, Hashable {
    let id: Int // Die WooCommerce-ID der Kategorie
    let appItem: AppNavigationItem
}

struct DisplayableSubCategory: Identifiable, Hashable {
    let id: Int
    let label: String
    let count: Int
}
