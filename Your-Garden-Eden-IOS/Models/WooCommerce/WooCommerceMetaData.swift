// Models/WooCommerce/WooCommerceMetaData.swift
import Foundation

struct WooCommerceMetaData: Codable, Identifiable, Hashable {
    let id: Int?
    let key: String
    let value: String // In deinem TypeScript war es `any`. Für Swift/Codable ist ein konkreter Typ besser.
                     // Wenn es wirklich verschiedenste Typen sein können, muss man es als JSONValue oder flexibler behandeln.
                     // Für den Anfang gehen wir von String aus, oder du passt es an, falls du weißt, welche Typen dort vorkommen.
                     // Alternativ: struct JSONValue: Codable, Hashable { let stringValue: String? ... let intValue: Int? ... }
                     // Oder wenn es immer ein Dictionary ist: let value: [String: String]?
}
