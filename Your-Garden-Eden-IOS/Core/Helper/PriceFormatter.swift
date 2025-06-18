// DATEI: PriceFormatter.swift
// PFAD: Helper/PriceFormatter.swift
// VERSION: PHOENIX 3.0 (BEREINIGT)
// ZWECK: Stellt zustandslose Funktionen zur Verfügung, um Preisangaben
//        in ein anzeigefreundliches Format für die Benutzeroberfläche umzuwandeln.
//        Greift für String-Operationen auf die zentrale `String+Utilities`-Erweiterung zu.

import Foundation
import RegexBuilder

public struct PriceFormatter {
    
    public struct FormattedPrice {
        public let display: String
        public let strikethrough: String?
    }
    
    public static func formatPriceString(from htmlString: String?, fallbackPrice: String, currencySymbol: String = "€") -> FormattedPrice {
        guard let html = htmlString, !html.isEmpty else {
            return FormattedPrice(display: formatSimplePrice(fallbackPrice, currencySymbol: currencySymbol), strikethrough: nil)
        }

        let delRegex = Regex { "<del>"; Capture { OneOrMore(.any, .reluctant) }; "</del>" }
        let insRegex = Regex { "<ins>"; Capture { OneOrMore(.any, .reluctant) }; "</ins>" }
        
        var salePrice: String?
        var regularPrice: String?

        if let saleMatch = html.firstMatch(of: insRegex)?.1, let delMatch = html.firstMatch(of: delRegex)?.1 {
            // Greift jetzt auf die öffentliche `strippingHTML()`-Funktion zu.
            salePrice = String(saleMatch).strippingHTML()
            regularPrice = String(delMatch).strippingHTML()
        } else {
            salePrice = html.strippingHTML()
        }
        
        let finalDisplayPrice = formatSimplePrice(salePrice ?? fallbackPrice, currencySymbol: currencySymbol)
        let finalStrikethroughPrice = regularPrice != nil ? formatSimplePrice(regularPrice!, currencySymbol: currencySymbol) : nil

        return FormattedPrice(display: finalDisplayPrice, strikethrough: finalStrikethroughPrice)
    }
    
    public static func calculatePriceRange(from variations: [WooCommerceProductVariation], currencySymbol: String = "€") -> String? {
        let prices = variations.compactMap { Double($0.price) }
        
        guard let minPrice = prices.min(), let maxPrice = prices.max(), minPrice != maxPrice else {
            return nil
        }
        
        let minFormatted = String(format: "%.2f", minPrice)
        let maxFormatted = String(format: "%.2f", maxPrice)
        
        return "\(minFormatted)\(currencySymbol) - \(maxFormatted)\(currencySymbol)"
    }
    
    /// BEREINIGUNG: Die Funktion wurde umbenannt, um ihre Aufgabe klarer zu machen,
    /// da sie nicht nur formatiert, sondern auch das Währungssymbol hinzufügt, falls es fehlt.
    public static func formatPrice(_ price: String, currencySymbol: String = "€") -> String {
        return price.contains(currencySymbol) ? price : "\(price)\(currencySymbol)"
    }
    
    /// Der alte Name wird als private Funktion beibehalten, um die interne Logik nicht zu brechen.
    private static func formatSimplePrice(_ price: String, currencySymbol: String) -> String {
        return self.formatPrice(price, currencySymbol: currencySymbol)
    }
}
