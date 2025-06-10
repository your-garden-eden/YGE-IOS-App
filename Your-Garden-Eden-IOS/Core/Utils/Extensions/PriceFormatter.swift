import Foundation
import UIKit

struct PriceFormatter {

    struct FormattedPrice {
        let display: String
        let strikethrough: String?
    }
    
    // +++ NEUE, EINFACHE FUNKTION ZUR KORREKTEN FORMATTIERUNG +++
    /// Formatiert einen einfachen Preis-String (z.B. "19.99") in einen lokalisierten String (z.B. "19,99 €").
    /// Diese Funktion ist ideal für Preise, die bereits als reine Zahlen vorliegen (wie bei Variationen).
    static func formatPrice(_ priceString: String?, currencySymbol: String) -> String {
        // 1. Stelle sicher, dass wir einen gültigen String haben.
        guard let validPriceString = priceString, !validPriceString.isEmpty else {
            return "" // oder einen Platzhalter wie "N/A"
        }
        
        // 2. Konvertiere den String in eine Zahl (Double). Ersetze Kommas, um sicherzugehen.
        let numberString = validPriceString.replacingOccurrences(of: ",", with: ".")
        guard let priceNumber = Double(numberString) else {
            return "\(validPriceString)\(currencySymbol)" // Fallback, falls Konvertierung fehlschlägt
        }
        
        // 3. Verwende einen NumberFormatter für die korrekte deutsche Darstellung.
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        
        // 4. Formatiere die Zahl und füge das Währungssymbol hinzu.
        if let formattedNumber = formatter.string(from: NSNumber(value: priceNumber)) {
            return "\(formattedNumber) \(currencySymbol)"
        } else {
            return "\(validPriceString) \(currencySymbol)" // Weiterer Fallback
        }
    }
    
    static func formatPriceString(from htmlString: String?, fallbackPrice: String, currencySymbol: String) -> FormattedPrice {
        guard let validString = htmlString, !validString.isEmpty else {
            // Kein HTML -> einfachen Preis mit der neuen Funktion formatieren.
            let formattedFallback = formatPrice(fallbackPrice, currencySymbol: currencySymbol)
            return FormattedPrice(display: formattedFallback, strikethrough: nil)
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
            let formattedFallback = formatPrice(fallbackPrice, currencySymbol: currencySymbol)
            return FormattedPrice(display: formattedFallback, strikethrough: nil)
        }
        
        // Wenn alles andere fehlschlägt, den geparsten String als einzelnen Preis anzeigen.
        return FormattedPrice(display: plainString, strikethrough: nil)
    }
    
    /// **NEU:** Extrahiert Preise sicher mit Regex, um den HTML-Parser zu umgehen.
    private static func extractPricesWithRegex(from html: String, currencySymbol: String) -> FormattedPrice? {
        let regex = try! NSRegularExpression(pattern: "[0-9.,]+")
        let results = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let prices = results.map { String(html[Range($0.range, in: html)!]) }

        switch prices.count {
        case 2:
            // Zwei Preise gefunden -> Sale-Preis. Wir formatieren sie mit der neuen Funktion.
            let strikethroughPrice = formatPrice(prices[0], currencySymbol: currencySymbol)
            let displayPrice = formatPrice(prices[1], currencySymbol: currencySymbol)
            return FormattedPrice(display: displayPrice, strikethrough: strikethroughPrice)
        case 1:
            // Ein einzelner Preis im HTML.
            let displayPrice = formatPrice(prices[0], currencySymbol: currencySymbol)
            return FormattedPrice(display: displayPrice, strikethrough: nil)
        default:
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
}
