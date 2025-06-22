// DATEI: AttributeModels.swift
// PFAD: Models/AttributeModels.swift
// VERSION: 1.2 - FINALER FILTER-FIX
// STATUS: MODIFIZIERT & STABILISIERT

import Foundation

/// Repräsentiert die Definition eines globalen Produktattributs (z.B. "Farbe", "Material").
public struct WooCommerceAttributeDefinition: Decodable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let type: String?
    public let order_by: String?
    public let has_archives: Bool?
    
    public static func == (lhs: WooCommerceAttributeDefinition, rhs: WooCommerceAttributeDefinition) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Repräsentiert einen einzelnen auswählbaren Wert ("Term") für ein Attribut.
public struct WooCommerceAttributeTerm: Decodable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let description: String?
    
    // KORREKTUR: Die Eigenschaft wird als optional deklariert, da sie in der
    // Server-Antwort für einige Terms fehlen kann.
    public let menu_order: Int?
    
    public let count: Int
    
    public static func == (lhs: WooCommerceAttributeTerm, rhs: WooCommerceAttributeTerm) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
