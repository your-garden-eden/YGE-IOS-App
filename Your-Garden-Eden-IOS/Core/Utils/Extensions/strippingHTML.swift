//
//  String+Extensions.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

import Foundation

extension String {
    
    /// **NEUE, ROBUSTE IMPLEMENTIERUNG**
    /// Wandelt einen HTML-String sicher in einen reinen Text-String um.
    /// Diese Methode verwendet Apples NSAttributedString, um sowohl HTML-Tags als auch Entitäten (wie   oder €) korrekt zu verarbeiten.
    func strippingHTML() -> String {
        // Stellt sicher, dass die Eingabe nicht leer ist.
        guard !self.isEmpty else { return "" }
        
        // Konvertiert den String in Daten, die von NSAttributedString gelesen werden können.
        guard let data = self.data(using: .utf8) else {
            return self // Falls die Konvertierung fehlschlägt, den Originalstring zurückgeben.
        }
        
        // Definiert die Optionen für das Lesen des HTML-Dokuments.
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        // Versucht, den HTML-Code in einen Attributed String zu parsen.
        // Wenn dies gelingt, gibt die .string-Eigenschaft den reinen Text zurück.
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        
        // Fallback: Sollte die obere Methode wider Erwarten fehlschlagen,
        // wird zumindest versucht, die offensichtlichen Tags zu entfernen.
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
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
