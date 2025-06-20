// DATEI: PriceFormatter.swift
// PFAD: Helper/PriceFormatter.swift
// VERSION: PHOENIX 5.1 (PREIS-UPDATE)
// ÄNDERUNG: Die Funktion `formatPriceString` wurde fundamental überarbeitet,
//           um flexibel einen oder zwei Preise aus dem HTML-String zu extrahieren.

import Foundation

public struct PriceFormatter {
    
    public struct FormattedPrice {
        public let display: String
        public let strikethrough: String?
    }
    
    public static func formatPriceFromMinorUnit(value: String, minorUnit: Int) -> String {
        guard let decimalValue = Decimal(string: value) else {
            return formatCurrency("0")
        }
        let divisor = pow(Decimal(10), minorUnit)
        let actualValue = decimalValue / divisor
        return formatCurrency(String(describing: actualValue))
    }

    public static func formatDisplayPrice(for product: WooCommerceProduct) -> FormattedPrice {
        if let range = product.priceRangeDisplay {
            let components = range.components(separatedBy: "-")
            if components.count == 2, let min = Double(components[0]), let max = Double(components[1]) {
                let minFormatted = String(format: "%.2f €", min)
                let maxFormatted = String(format: "%.2f €", max)
                return FormattedPrice(display: "\(minFormatted) - \(maxFormatted)", strikethrough: nil)
            }
        }
        return formatPriceString(from: product.price_html, fallbackPrice: product.price)
    }

    // ===================================================================
    // **BEGINN OPERATION "PREIS-UPDATE"**
    // ===================================================================
    public static func formatPriceString(from htmlString: String?, fallbackPrice: String, currencySymbol: String = "€") -> FormattedPrice {
        let cleanHtml = (htmlString ?? "").strippingHTML()
        
        // Eine robustere Regex, die jede Zahl (mit optionalen Komma/Punkt-Dezimalen) findet.
        let priceRegex = /([0-9]+(?:[.,][0-9]+)?)/
        let matches = cleanHtml.matches(of: priceRegex)
        
        // Konvertiere alle gefundenen Übereinstimmungen in Double-Werte.
        let prices = matches.compactMap { Double(String($0.output.1).replacingOccurrences(of: ",", with: ".")) }
        
        var displayPrice: Double?
        var strikethroughPrice: Double?
        
        switch prices.count {
        case 2:
            // Wenn zwei Preise gefunden werden, ist es ein Sale.
            displayPrice = prices.min()
            strikethroughPrice = prices.max()
        case 1:
            // Wenn ein Preis gefunden wird, ist es der Standardpreis.
            displayPrice = prices.first
        default:
            // Wenn keine Preise im HTML gefunden werden, versuche, den Fallback-Preis zu verwenden.
            displayPrice = Double(fallbackPrice.replacingOccurrences(of: ",", with: "."))
        }
        
        let finalDisplayPrice = formatCurrency(String(displayPrice ?? 0.0))
        let finalStrikethroughPrice = strikethroughPrice != nil ? formatCurrency(String(strikethroughPrice!)) : nil

        return FormattedPrice(display: finalDisplayPrice, strikethrough: finalStrikethroughPrice)
    }
    // ===================================================================
    // **ENDE OPERATION "PREIS-UPDATE"**
    // ===================================================================
    
    public static func calculatePriceRange(from variations: [WooCommerceProductVariation]) -> String? {
        let prices = variations.compactMap { Double($0.price) }
        guard let minPrice = prices.min(), let maxPrice = prices.max(), minPrice != maxPrice else { return nil }
        return "\(minPrice)-\(maxPrice)"
    }
    
    private static func formatCurrency(_ priceString: String) -> String {
        let cleanedString = priceString.replacingOccurrences(of: ",", with: ".").filter("0123456789.".contains)
        if let priceValue = Double(cleanedString) {
            return String(format: "%.2f €", priceValue)
        }
        return "0.00 €"
    }

    public static func formatPrice(_ price: String, currencySymbol: String = "€") -> String {
        return formatCurrency(price)
    }
}
