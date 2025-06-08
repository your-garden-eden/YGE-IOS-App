import Foundation
import UIKit

struct PriceFormatter {

    struct FormattedPrice {
        let display: String
        let strikethrough: String?
    }
    
    static func formatPriceString(from htmlString: String?, fallbackPrice: String, currencySymbol: String) -> FormattedPrice {
        guard let validString = htmlString, !validString.isEmpty else {
            // Kein HTML -> einfacher Preis
            return FormattedPrice(display: "\(currencySymbol)\(fallbackPrice)", strikethrough: nil)
        }

        // --- NEUE, SICHERE LOGIK ---

        // 1. VERSUCH: Sale-Preis mit Regex finden (sicherste Methode)
        if let salePrice = extractPricesWithRegex(from: validString, currencySymbol: currencySymbol) {
            return salePrice
        }
        
        // 2. VERSUCH: HTML parsen (nur wenn Regex fehlschlägt)
        let plainString = parseHtmlOnMainThread(htmlString: validString)
        
        if plainString.contains("–") {
            let components = plainString.components(separatedBy: "–").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if let firstPrice = components.first, !firstPrice.isEmpty {
                return FormattedPrice(display: "Ab \(firstPrice)", strikethrough: nil)
            }
        }
        
        if plainString.isEmpty {
             // Wenn das Parsen fehlschlägt, den Fallback-Preis verwenden
            return FormattedPrice(display: "\(currencySymbol)\(fallbackPrice)", strikethrough: nil)
        }
        
        // Wenn alles andere fehlschlägt, den geparsten String als einzelnen Preis anzeigen.
        return FormattedPrice(display: plainString, strikethrough: nil)
    }
    
    /// **NEU:** Extrahiert Preise sicher mit Regex, um den HTML-Parser zu umgehen.
    private static func extractPricesWithRegex(from html: String, currencySymbol: String) -> FormattedPrice? {
        // Sucht nach Zahlen (mit Komma/Punkt) im String.
        let regex = try! NSRegularExpression(pattern: "[0-9.,]+")
        let results = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let prices = results.map { String(html[Range($0.range, in: html)!]) }

        switch prices.count {
        case 2:
            // Zwei Preise gefunden -> Sale-Preis. Annahme: der erste ist der alte Preis.
            // Wir formatieren sie explizit mit dem Währungssymbol.
            let strikethroughPrice = "\(currencySymbol)\(prices[0])"
            let displayPrice = "\(currencySymbol)\(prices[1])"
            return FormattedPrice(display: displayPrice, strikethrough: strikethroughPrice)
        case 1:
            // Ein einzelner Preis im HTML.
            let displayPrice = "\(currencySymbol)\(prices[0])"
            return FormattedPrice(display: displayPrice, strikethrough: nil)
        default:
            // Kein oder mehr als zwei Preise gefunden, wir können keine Annahme treffen.
            return nil
        }
    }

    /// Kapselt die unsichere `NSAttributedString`-Arbeit.
    private static func parseHtmlOnMainThread(htmlString: String) -> String {
        guard let data = htmlString.data(using: .utf8) else { return "" }

        if Thread.isMainThread {
            return performHtmlParsing(data: data)
        } else {
            return DispatchQueue.main.sync {
                return performHtmlParsing(data: data)
            }
        }
    }
    
    /// Führt die eigentliche, potenziell abstürzende Operation durch.
    private static func performHtmlParsing(data: Data) -> String {
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
            return attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("PriceFormatter CRITICAL: Could not parse HTML. Returning empty string. Error: \(error)")
            return ""
        }
    }
    
    // Die alte, veraltete Funktion wird komplett entfernt, um Verwirrung zu vermeiden.
}
