import Foundation

// Dieses Modell wird nicht mehr aktiv verwendet, kann aber für zukünftige Features nützlich sein.
struct DisplayableMainCategory: Identifiable, Hashable {
    let id: Int // Die WooCommerce-ID der Kategorie
    let appItem: AppNavigationItem
}

// Dieses Modell wird nicht mehr aktiv verwendet, kann aber für zukünftige Features nützlich sein.
struct DisplayableSubCategory: Identifiable, Hashable {
    var id: String { slug }
    let label: String
    let count: Int
    let slug: String
}

