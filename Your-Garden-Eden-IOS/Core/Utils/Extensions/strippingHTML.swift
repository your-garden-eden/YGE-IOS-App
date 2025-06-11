import Foundation

extension String {
    
    /// Entfernt HTML-Tags und dekodiert gängige HTML-Entitäten auf eine thread-sichere, SYNCHRONE Weise.
    /// Diese Methode verwendet keine UI-Frameworks und kann von jedem Thread aus aufgerufen werden.
    func strippingHTML() -> String {
        guard !self.isEmpty else { return "" }
        
        // 1. HTML-Tags mit Regex entfernen.
        var result = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        // 2. Ein Array von Tupeln für die Ersetzungen.
        // DIE REIHENFOLGE IST ENTSCHEIDEND: & muss immer zuerst ersetzt werden.
        let htmlEntities: [(String, String)] = [
            ("&", "&"),    // Ampersand
            (" ", " "),   // Non-breaking space
            ("€", "€"),   // Euro
            ("<", "<"),     // Less than
            (">", ">"),     // Greater than
//            (""", "\""),  // Double quote
            ("'", "'")    // Single quote
        ]
        
        // 3. Jede Entität durch ihr Zeichen ersetzen.
        for (entity, character) in htmlEntities {
            result = result.replacingOccurrences(of: entity, with: character)
        }
        
        // 4. Ergebnis zurückgeben und überflüssige Leerzeichen am Anfang/Ende entfernen.
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // ... (Der Rest deiner Erweiterung bleibt unverändert) ...
    func displayableAttributeName() -> String {
        var nameToProcess = self
        if nameToProcess.hasPrefix("pa_") { nameToProcess = String(nameToProcess.dropFirst(3)) }
        let words = nameToProcess.replacingOccurrences(of: "_", with: " ").split(separator: " ")
        return words.map { $0.capitalized }.joined(separator: " ")
    }
    func capitalizedSentence() -> String {
        guard let firstCharacter = self.first else { return "" }
        return firstCharacter.uppercased() + self.dropFirst()
    }
    func asURL() -> URL? {
        return URL(string: self)
    }
}
