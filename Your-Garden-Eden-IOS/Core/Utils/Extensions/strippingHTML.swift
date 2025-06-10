// Core/Utils/Extensions/String+Extensions.swift
import Foundation

extension String {
    
    /// Entfernt HTML-Tags sicher aus einem String und dekodiert gängige HTML-Entities.
    func strippingHTML() -> String {
        // Wenn der String leer ist, direkt einen leeren String zurückgeben.
        guard !self.isEmpty else { return "" }
        
        // 1. HTML-Tags mit Regex entfernen
        let pattern = "<[^>]+>"
        var strippedString = self.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
        
        // 2. Gängige HTML-Entities dekodieren (jede Ersetzung auf einer eigenen Zeile für Lesbarkeit)
        strippedString = strippedString.replacingOccurrences(of: " ", with: " ") // non-breaking space
        strippedString = strippedString.replacingOccurrences(of: "&", with: "&")
        strippedString = strippedString.replacingOccurrences(of: "<", with: "<")
        strippedString = strippedString.replacingOccurrences(of: ">", with: ">")
//        strippedString = strippedString.replacingOccurrences(of: """, with: "\"") // KORREKTUR: """ statt '"""'
        strippedString = strippedString.replacingOccurrences(of: "'", with: "'")
        strippedString = strippedString.replacingOccurrences(of: "€", with: "€")
        
        // 3. Ergebnis zurückgeben und überflüssige Leerzeichen am Anfang/Ende entfernen
        return strippedString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Konvertiert einen Attribut-Slug (z.B. "pa_farbe") in einen besser lesbaren Anzeigenamen.
    func displayableAttributeName() -> String {
        var nameToProcess = self
        if nameToProcess.hasPrefix("pa_") {
            nameToProcess = String(nameToProcess.dropFirst(3))
        }
        let words = nameToProcess.replacingOccurrences(of: "_", with: " ").split(separator: " ")
        return words.map { $0.capitalized }.joined(separator: " ")
    }
    
    /// Macht nur den ersten Buchstaben des gesamten Strings groß.
    func capitalizedSentence() -> String {
        guard let firstCharacter = self.first else {
            return ""
        }
        return firstCharacter.uppercased() + self.dropFirst()
    }
    
    /// Konvertiert den String in ein optionales URL-Objekt.
    func asURL() -> URL? {
        return URL(string: self)
    }
}
// KORREKTUR: Die überflüssige schließende Klammer am Ende wurde entfernt.
