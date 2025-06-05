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
    let imageFilename: String? // <-- NEU
    let subItems: [AppSubNavigationItem]?
}
