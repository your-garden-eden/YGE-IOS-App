// Core/Extensions/String+Extensions.swift

import Foundation

extension String {
    
    /// Entfernt HTML-Tags und bereinigt gängige HTML-Entitäten für die Anzeige in der App.
    func strippingHTML() -> String {
        guard !self.isEmpty else { return "" }
        
        var result = self
        
        // --- FINALE KORREKTUR: Ersetzt die häufigsten HTML-Entitäten in der richtigen Reihenfolge ---
        result = result.replacingOccurrences(of: " ", with: " ")
        result = result.replacingOccurrences(of: "€", with: "€")
        result = result.replacingOccurrences(of: "&", with: "&")
        result = result.replacingOccurrences(of: "<", with: "<")
        result = result.replacingOccurrences(of: ">", with: ">")
      
        result = result.replacingOccurrences(of: "'", with: "'")
        
        // Entfernt alle verbleibenden HTML-Tags
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        // Entfernt überflüssige Leerzeichen am Anfang und Ende
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
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
