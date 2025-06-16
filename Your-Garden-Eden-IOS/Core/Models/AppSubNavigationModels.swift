import Foundation

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
    // Die imageFilename-Eigenschaft wurde hier entfernt.
}
