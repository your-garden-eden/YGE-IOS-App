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

    // --- HIER IST DIE WICHTIGE HINZUFÜGUNG ---
    // Diese Variable wird die von der API geladenen Daten halten.
    // Sie ist 'var', weil sie nach der Initialisierung gesetzt wird.
    // Sie ist 'nil', bis die Daten geladen und zugewiesen sind.
    var wooCommerceCategory: WooCommerceCategory?

    // Wir müssen die Hashable-Konformität manuell implementieren,
    // damit die neue, optionale Variable den Hash nicht beeinflusst.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(mainCategorySlug)
        hasher.combine(label)
    }

    // Ebenso für die Gleichheit (Equatable).
    static func == (lhs: AppNavigationItem, rhs: AppNavigationItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.mainCategorySlug == rhs.mainCategorySlug &&
               lhs.label == rhs.label
    }
}
