// Models/WooCommerce/WooCommerceAttribute.swift
import Foundation

// Dies ist Ihre existierende Struktur. Sie bleibt unverändert.
struct WooCommerceAttribute: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String? // Optional
    let position: Int
    let visible: Bool
    let variation: Bool
    let options: [String]
}


// MARK: - Erweiterung für WooCommerceAttribute
// HINZUGEFÜGT: Diese Erweiterung fügt die fehlende Funktion `slugOrNameAsSlug()` hinzu.
extension WooCommerceAttribute {
    
    /// Gibt den Slug des Attributs zurück.
    /// Wenn kein expliziter Slug vorhanden ist, wird einer aus dem `name` generiert.
    /// Beispiel: "Stoff Farbe" -> "stoff-farbe"
    func slugOrNameAsSlug() -> String {
        // 1. Bevorzuge den existierenden Slug, falls er gültig ist.
        if let slug = self.slug, !slug.trimmingCharacters(in: .whitespaces).isEmpty {
            return slug
        }
        
        // 2. Andernfalls, generiere einen Slug aus dem Namen.
        let baseSlug = name.lowercased()
            // Ersetze gängige Trennzeichen durch einen Standard-Bindestrich.
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
        
        // Definiere die Zeichen, die in einem Slug erlaubt sind (Buchstaben, Zahlen, Bindestrich).
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        
        // Entferne alle Zeichen, die NICHT erlaubt sind.
        var finalSlug = baseSlug.components(separatedBy: allowedCharacters.inverted).joined()
        
        // Stelle sicher, dass nicht mehrere Bindestriche aufeinanderfolgen (z.B. "a--b" wird zu "a-b").
        while finalSlug.contains("--") {
            finalSlug = finalSlug.replacingOccurrences(of: "--", with: "-")
        }
        
        return finalSlug
    }
}


// MARK: - Attribut für eine Produkt-Variation
// WICHTIG: Ihr `AttributeOptionCalculator` benötigt auch eine Funktion für das Attribut,
// das zu einer *Variation* gehört. Normalerweise hat dieses eine etwas andere Struktur.
// Fügen Sie dieses Struct hinzu, falls es in Ihrem Projekt noch nicht existiert.
// Passen Sie es an, falls Ihre Struktur anders aussieht.
struct WooCommerceVariationAttribute: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String?
    let option: String // Die spezifische gewählte Option, z.B. "Blau"
}


// MARK: - Erweiterung für WooCommerceVariationAttribute
// HINZUGEFÜGT: Diese Erweiterung fügt die zweite fehlende Funktion `optionAsSlug()` hinzu.
extension WooCommerceVariationAttribute {
    
    /// Generiert einen Slug aus der `option`-Eigenschaft.
    /// Beispiel: "Dunkel Blau" -> "dunkel-blau"
    func optionAsSlug() -> String {
        let baseSlug = option.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
            
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        var finalSlug = baseSlug.components(separatedBy: allowedCharacters.inverted).joined()
        
        while finalSlug.contains("--") {
            finalSlug = finalSlug.replacingOccurrences(of: "--", with: "-")
        }
        
        return finalSlug
    }
}
