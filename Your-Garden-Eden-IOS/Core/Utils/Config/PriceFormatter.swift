import Foundation
import UIKit // Wir benötigen UIKit für NSAttributedString

struct PriceFormatter {
    
    /// Formatiert einen Preis-String sicher, indem die HTML-Verarbeitung auf dem Main-Thread erzwungen wird.
    static func formatPrice(from htmlString: String?) async -> String? {
        guard let validString = htmlString, !validString.isEmpty else { return nil }
        guard let data = validString.data(using: .utf8) else { return validString }

        // --- DIE KORREKTUR ---
        // Wir erzwingen, dass dieser Codeblock auf dem Main-Thread ausgeführt wird.
        // Dies ist notwendig, da NSAttributedString mit dem HTML-Parser nicht thread-sicher ist.
        let plainString = await MainActor.run {
            do {
                let attributedString = try NSAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil
                )
                return attributedString.string
            } catch {
                print("PriceFormatter Warning: Could not parse HTML string. Returning raw string. Error: \(error)")
                return validString // Fallback, wenn das Parsen fehlschlägt
            }
        }

        let finalString = plainString
            .replacingOccurrences(of: ".", with: ",")
            .replacingOccurrences(of: "-", with: " – ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if finalString.isEmpty { return "Preis auf Anfrage" }
        if !finalString.contains("–") && !finalString.lowercased().contains("ab") { return "Ab \(finalString)" }
        return finalString
    }
}
