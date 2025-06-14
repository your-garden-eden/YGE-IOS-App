// Path: Your-Garden-Eden-IOS/Core/Models/AppNavigationModels.swift

import Foundation

// Modelle, die sich rein auf die statische Navigation der App beziehen.

struct AppNavigationItem: Identifiable, Hashable {
    let id = UUID()
    let mainCategorySlug: String
    let label: String
    let i18nId: String
    let imageFilename: String?
    let subItems: [AppSubNavigationItem]?
}

struct AppSubNavigationItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let i18nId: String
    let linkSlug: String
}
