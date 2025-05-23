struct WooCommerceCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
    let parent: Int
    let description: String
    let display: String // Oder ein spezifischerer Enum, z.B. DisplayType: String, Codable, Hashable
    let image: WooCommerceImage? // WooCommerceImage muss nicht Hashable sein, wenn manuell implementiert
    let menuOrder: Int         // Korrigierter Name (camelCase)
    let count: Int             // Korrigierter Typ (Int)

    enum CodingKeys: String, CodingKey {
        case id, name, slug, parent, description, display, image, count
        case menuOrder = "menu_order"
    }

    // Manuelle Hashable Implementierung (nur id berücksichtigen)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Manuelle Equatable Implementierung (Teil von Hashable)
    static func == (lhs: WooCommerceCategory, rhs: WooCommerceCategory) -> Bool {
        return lhs.id == rhs.id
    }
}

// Und deine WooCommerceImage müsste dann nicht zwingend Hashable sein,
// aber wenn sie es ist, ist die automatische Synthese für WooCommerceCategory einfacher.
// struct WooCommerceImage: Codable, Identifiable /*, Hashable */ { ... }
