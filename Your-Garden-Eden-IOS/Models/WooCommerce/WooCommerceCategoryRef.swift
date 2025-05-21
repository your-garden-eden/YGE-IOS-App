import Foundation

struct WooCommerceCategoryRef: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let slug: String

    static var placeholder: WooCommerceCategoryRef {
        WooCommerceCategoryRef(id: 0, name: "Kategorie", slug: "kategorie")
    }
}
