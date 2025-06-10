// Core/Models/Navigation/AppNavigationModels.swift

import Foundation

// Stellt ein Unter-Navigationselement dar (z.B. eine Unterkategorie).
struct AppSubNavigationItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let i18nId: String
    let linkSlug: String
    let iconFilename: String?
}

// Stellt ein Haupt-Navigationselement dar (z.B. eine Hauptkategorie).
struct AppNavigationItem: Identifiable, Hashable {
    let id = UUID()
    let mainCategorySlug: String
    let label: String
    let i18nId: String
    let imageFilename: String?
    let subItems: [AppSubNavigationItem]?

    var wooCommerceCategory: WooCommerceCategory?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(mainCategorySlug)
        hasher.combine(label)
    }

    static func == (lhs: AppNavigationItem, rhs: AppNavigationItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.mainCategorySlug == rhs.mainCategorySlug &&
               lhs.label == rhs.label
    }
}
