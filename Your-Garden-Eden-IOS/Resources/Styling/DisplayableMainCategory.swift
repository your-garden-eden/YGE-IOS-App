//
//  DisplayableMainCategory.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 13.06.25.
//


// Dateiname: Models/SharedDisplayModels.swift

import Foundation

// Ein Datenmodell, das eine Hauptkategorie darstellt, die in der UI angezeigt werden kann.
struct DisplayableMainCategory: Identifiable, Hashable {
    let id: Int
    let appItem: AppNavigationItem
}

// Ein Datenmodell, das eine Unterkategorie darstellt, die in der UI angezeigt werden kann.
struct DisplayableSubCategory: Identifiable, Hashable {
    let id: Int
    let label: String
    let count: Int
}