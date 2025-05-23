// YGE-IOS-App/Core/Models/WooCommerce/Shared/WooCommerceMetaData.swift (Beispielpfad)
import Foundation

struct WooCommerceMetaData: Codable, Hashable {
    let id: Int? // Oft von der API für bestimmte Metadaten nicht geliefert oder nicht relevant
    let key: String
    let value: ValueType // Unser angepasster Enum für den Wert

    // Optional: Wenn deine API 'value' manchmal als einfaches Objekt und manchmal als Array von Objekten sendet,
    // dann wird die Dekodierung komplexer und erfordert evtl. einen benutzerdefinierten init(from decoder: Decoder)
    // für WooCommerceMetaData selbst. Für dieses Beispiel gehen wir von einem einzelnen Wert aus.
}

// Unser Enum, das die verschiedenen möglichen Typen für metaData.value repräsentiert.
// Dieses Enum muss selbst Codable und Hashable sein.
enum ValueType: Hashable { // Codable wird manuell implementiert
    case string(String)
    case int(Int)
    case double(Double) // Für Preise oder andere Fließkommazahlen
    case bool(Bool)
    case array([ValueType]) // Für verschachtelte Arrays
    case dictionary([String: ValueType]) // Für verschachtelte Objekte
    case null // Um explizit JSON null darzustellen

    // Um Hashable zu sein, wenn Arrays/Dictionaries enthalten sind (vereinfachte Implementierung)
    // Für eine robuste Hashable-Implementierung mit Arrays/Dictionaries müsste man tiefer gehen.
    // Oft reicht es für den Anwendungsfall, dass die primitiven Typen korrekt gehasht werden.
    func hash(into hasher: inout Hasher) {
        switch self {
        case .string(let val): hasher.combine("string"); hasher.combine(val)
        case .int(let val): hasher.combine("int"); hasher.combine(val)
        case .double(let val): hasher.combine("double"); hasher.combine(val)
        case .bool(let val): hasher.combine("bool"); hasher.combine(val)
        case .null: hasher.combine("null")
        // Hash für Array/Dictionary ist komplexer, hier vereinfacht oder weggelassen, wenn nicht primär als Key genutzt
        case .array(let arr): hasher.combine("array"); arr.forEach { $0.hash(into: &hasher) } // Beispielhafte rekursive Hashung
        case .dictionary(let dict):
            hasher.combine("dictionary")
            dict.keys.sorted().forEach { key in // Sortieren für konsistente Hash-Reihenfolge
                hasher.combine(key)
                dict[key]?.hash(into: &hasher)
            }
        }
    }

    static func == (lhs: ValueType, rhs: ValueType) -> Bool {
        switch (lhs, rhs) {
        case (.string(let l), .string(let r)): return l == r
        case (.int(let l), .int(let r)): return l == r
        case (.double(let l), .double(let r)): return l == r
        case (.bool(let l), .bool(let r)): return l == r
        case (.null, .null): return true
        case (.array(let l), .array(let r)): return l == r // Erfordert, dass ValueType Equatable ist
        case (.dictionary(let l), .dictionary(let r)): return l == r // Erfordert, dass ValueType Equatable ist
        default: return false
        }
    }
}

// Manuelle Codable-Implementierung für ValueType, da es verschiedene Typen handhaben muss.
extension ValueType: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let boolVal = try? container.decode(Bool.self) {
            self = .bool(boolVal)
        } else if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let doubleVal = try? container.decode(Double.self) {
            self = .double(doubleVal)
        } else if let stringVal = try? container.decode(String.self) {
            self = .string(stringVal)
        } else if let arrayVal = try? container.decode([ValueType].self) {
            self = .array(arrayVal)
        } else if let dictionaryVal = try? container.decode([String: ValueType].self) {
            self = .dictionary(dictionaryVal)
        } else {
            throw DecodingError.typeMismatch(ValueType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported value type for meta data value. Expected String, Int, Double, Bool, Array, Dictionary or Null."))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let stringVal):
            try container.encode(stringVal)
        case .int(let intVal):
            try container.encode(intVal)
        case .double(let doubleVal):
            try container.encode(doubleVal)
        case .bool(let boolVal):
            try container.encode(boolVal)
        case .array(let arrayVal):
            try container.encode(arrayVal)
        case .dictionary(let dictionaryVal):
            try container.encode(dictionaryVal)
        case .null:
            try container.encodeNil()
        }
    }
}
