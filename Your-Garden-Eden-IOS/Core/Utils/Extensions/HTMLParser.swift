import Foundation
import SwiftUI

/// Ein absolut sicherer Parser, der HTML-Tags aus einem String entfernt,
/// anstatt zu versuchen, sie zu interpretieren. Verhindert SIGABRT-Abstürze.
struct HTMLParser {
    
    /// Konvertiert einen HTML-String sicher in einen AttributedString,
    /// indem alle HTML-Tags mithilfe einer Regular Expression entfernt werden.
    /// Diese Methode ist absturzsicher.
    /// - Parameter html: Der potenziell fehlerhafte HTML-String.
    /// - Returns: Ein AttributedString, der nur den reinen Text enthält.
    static func parse(html: String) -> AttributedString {
        // Wenn der String leer ist, direkt eine leere AttributedString zurückgeben.
        guard !html.isEmpty else {
            return AttributedString()
        }
        
        // --- SICHERE OPERATION: HTML-TAGS MIT REGEX ENTFERNEN ---
        let pattern = "<[^>]+>"
        let strippedString = html.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
        
        // Zusätzlich müssen wir gängige HTML-Entities dekodieren.
        let decodedString = decodeHTMLEntities(from: strippedString)

        // Erstellt einen AttributedString aus dem sicheren "Plain Text".
        return AttributedString(decodedString)
    }
    
    /// Ersetzt gängige HTML-Entities durch ihre entsprechenden Zeichen.
    private static func decodeHTMLEntities(from text: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: " ", with: " ")
        result = result.replacingOccurrences(of: "&", with: "&")
        
        // --- DIE TATSÄCHLICHE KORREKTUR ---
        // Das Anführungszeichen ist jetzt korrekt mit einem Backslash versehen.
        
        
        result = result.replacingOccurrences(of: "<", with: "<")
        result = result.replacingOccurrences(of: ">", with: ">")
        result = result.replacingOccurrences(of: "€", with: "€")
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
