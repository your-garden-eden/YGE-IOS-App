// YGE-IOS-App/Core/Utils/Extensions/String+Extensions.swift
// (oder ein anderer passender Ort für deine Extensions, z.B. Core/Extensions/String+Extensions.swift)

import Foundation

extension String {
    
    /// Entfernt HTML-Tags aus einem String.
    ///
    /// Diese Regular Expression versucht, HTML-Tags zu entfernen.
    /// Es ist eine einfache Implementierung und könnte für sehr komplexes HTML ggf. nicht perfekt sein.
    /// - Returns: Der String ohne HTML-Tags.
    func strippingHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    /// Konvertiert einen Attribut-Slug (z.B. "pa_farbe" oder "material_typ") in einen besser lesbaren Anzeigenamen.
    /// Entfernt das Präfix "pa_", ersetzt Unterstriche durch Leerzeichen und macht den ersten Buchstaben jedes Wortes groß.
    /// - Returns: Ein für die Anzeige formatierter Attributname (z.B. "Farbe", "Material Typ").
    func displayableAttributeName() -> String {
        var nameToProcess = self
        
        // Entferne das "pa_" Präfix, falls vorhanden
        if nameToProcess.hasPrefix("pa_") {
            nameToProcess = String(nameToProcess.dropFirst(3))
        }
        
        // Ersetze Unterstriche durch Leerzeichen und mache die Anfangsbuchstaben der Wörter groß
        let words = nameToProcess.replacingOccurrences(of: "_", with: " ").split(separator: " ")
        return words.map { $0.capitalized }.joined(separator: " ")
    }

    /// Macht nur den ersten Buchstaben des gesamten Strings groß, der Rest bleibt unverändert.
    /// Beispiel: "hallo welt" -> "Hallo welt".
    /// - Returns: Der String mit großem Anfangsbuchstaben.
    func capitalizedSentence() -> String {
        guard let firstCharacter = self.first else {
            return "" // Leerer String, wenn der String leer ist
        }
        return firstCharacter.uppercased() + self.dropFirst()
    }
    
    /// Konvertiert den String in ein optionales URL-Objekt.
    /// - Returns: Ein `URL`-Objekt, wenn der String eine gültige URL ist, sonst `nil`.
    func asURL() -> URL? {
        return URL(string: self)
    }
}
