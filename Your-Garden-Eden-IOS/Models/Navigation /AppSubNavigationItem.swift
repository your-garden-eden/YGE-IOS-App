//
//  AppSubNavigationItem.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 30.05.25.
//


// Models/Navigation/AppNavigationItem.swift
import Foundation

struct AppSubNavigationItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let i18nId: String // Für zukünftige Lokalisierung
    let linkSlug: String // Bereinigter Slug für die Produktliste, z.B. "gartenmoebel-sofas"
    let iconFilename: String? // Optionaler Dateiname des Icons aus Assets.xcassets
}

struct AppNavigationItem: Identifiable, Hashable {
    let id = UUID()
    let mainCategorySlug: String // Slug der Hauptkategorie, z.B. "gartenmoebel"
    let label: String            // Angezeigter Name der Hauptkategorie, z.B. "Gartenmöbel"
    let i18nId: String           // Für zukünftige Lokalisierung
    let subItems: [AppSubNavigationItem]?
}