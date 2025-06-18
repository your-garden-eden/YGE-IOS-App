// DATEI: String+Utilities.swift
// PFAD: Helper/String+Utilities.swift
// VERSION: PHOENIX 2.0 (KORRIGIERT & KONSOLIDIERT)
// ZWECK: Stellt eine Sammlung von allgemeinen, öffentlichen und wiederverwendbaren
//        Erweiterungen für den `String`-Typ zur Verfügung.

import Foundation
import RegexBuilder

public extension String {
    
    /// Entfernt HTML-Tags aus einem String.
    /// Diese Funktion ist öffentlich, damit sie in der gesamten App verwendet werden kann
    /// (z.B. für Produktnamen, Beschreibungen, etc.).
    /// - Returns: Der String ohne HTML-Tags.
    func strippingHTML() -> String {
        let htmlTagRegex = /<.*?>/
        return self.replacing(htmlTagRegex, with: "")
    }
    
    /// Konvertiert den String in eine URL.
    /// - Returns: Ein `URL`-Objekt oder `nil`, wenn der String keine gültige URL darstellt.
    func asURL() -> URL? {
        return URL(string: self)
    }
    
    /// Erstellt eine URL-freundliche "Slug"-Version des Strings.
    /// Umlaute werden umgewandelt, alles wird in Kleinbuchstaben geschrieben
    /// und ungültige Zeichen werden entfernt.
    /// - Returns: Ein bereinigter "Slug"-String.
    func slugify() -> String {
        // Schritt 1: Konvertiert Umlaute und Akzente in ihre Basis-Buchstaben (z.B. "für" -> "fur").
        let baseString = self.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        // Regex, um alle ungültigen Zeichen zu finden (erlaubt sind nur a-z, 0-9 und Bindestriche).
        let invalidCharsRegex = /[^a-z0-9-]+/
        // Regex, um eine oder mehrere Folgen von Leerzeichen zu finden.
        let spacesToDashRegex = /\s+/
        
        // Führe die Ersetzungen aus.
        let processedString = baseString
            .replacing(spacesToDashRegex, with: "-")  // Ersetzt Leerzeichenfolgen durch einen Bindestrich
            .replacing(invalidCharsRegex, with: "")   // Entfernt alle verbleibenden ungültigen Zeichen
            
        return processedString
    }
}
