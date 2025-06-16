import Foundation
import RegexBuilder // Import für die moderne Regex-Syntax

extension String {
    
    /// Entfernt HTML-Tags aus einem String mithilfe einer modernen Swift-Regex.
    /// Diese Methode ist oft performanter und direkter als die Verwendung von NSAttributedString für diese spezifische Aufgabe.
    func strippingHTML() -> String {
        // MODERNISIERT: Die neue, deklarative Regex-Syntax von Swift.
        // Sie sucht nach einem '<', gefolgt von beliebigen Zeichen (nicht-gierig), die kein '>' sind, und dann einem '>'.
        let htmlTagRegex = /<.*?>/
        return self.replacing(htmlTagRegex, with: "")
    }
    
    /// Konvertiert den String in eine URL. An dieser Funktion gibt es nichts zu modernisieren,
    /// sie ist bereits optimal und sicher.
    func asURL() -> URL? {
        return URL(string: self)
    }
    
    /// Erstellt eine URL-freundliche "Slug"-Version des Strings.
    /// Diese modernisierte Version verwendet Regex für eine robustere und klarere Umwandlung.
    func slugify() -> String {
        // Schritt 1: Konvertiert Umlaute und Akzente in ihre Basis-Buchstaben (z.B. "für" -> "fur").
        let baseString = self.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        // MODERNISIERT: Deklarative Regex-Definitionen für bessere Lesbarkeit.
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
