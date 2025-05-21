import Foundation

struct WooCommerceCategory: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let slug: String
    let parent: Int
    let description: String
    let display: String
    let image: WooCommerceImage?
    let menuOrder: Int
    let count: Int

    enum CodingKeys: String, CodingKey {
        case id, name, slug, parent, description, display, image, count
        case menuOrder = "menu_order"
    }

    // Statische Placeholder-Instanz für Previews
    static var placeholder: WooCommerceCategory {
        WooCommerceCategory(
            id: 1, name: "Beispiel Kategorie", slug: "beispiel-kategorie", parent: 0,
            description: "Dies ist eine Beispielkategorie.", display: "products",
            image: WooCommerceImage.placeholder, // Nutzt den Placeholder von WooCommerceImage
            menuOrder: 1, count: 5
        )
    }
}
