//
//  WooCommerceAttributeDefinition.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 19.06.25.
//


// DATEI: AttributeModels.swift
// PFAD: Models/AttributeModels.swift
// VERSION: 1.0 (OPERATION PRÄZISIONSSCHLAG)
// ZWECK: Definiert die Datenmodelle für globale Produktattribute und deren
//        auswählbare Werte (Terms), wie sie von der WooCommerce API geliefert werden.

import Foundation

/// Repräsentiert die Definition eines globalen Produktattributs (z.B. "Farbe", "Material").
public struct WooCommerceAttributeDefinition: Decodable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let type: String // 'select' or 'text'
    public let order_by: String // 'menu_order', 'name', 'name_num', 'id'
    public let has_archives: Bool
    
    public static func == (lhs: WooCommerceAttributeDefinition, rhs: WooCommerceAttributeDefinition) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Repräsentiert einen einzelnen auswählbaren Wert ("Term") für ein Attribut.
/// Zum Beispiel "Blau" für das Attribut "Farbe".
public struct WooCommerceAttributeTerm: Decodable, Identifiable, Hashable, Equatable {
    public let id: Int
    public let name: String
    public let slug: String
    public let description: String?
    public let menu_order: Int
    public let count: Int
    
    public static func == (lhs: WooCommerceAttributeTerm, rhs: WooCommerceAttributeTerm) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}