// Path: Your-Garden-Eden-IOS/Helper/PriceFormatter.swift
// VERSION 2.1 (FINAL - Mit Preisspannen-Berechnung)

import Foundation
import RegexBuilder

struct PriceFormatter {
    
    /// Hält einen formatierten Preis und einen optionalen, durchgestrichenen alten Preis.
    struct FormattedPrice {
        let display: String
        let strikethrough: String?
    }
    
    /// Eine einfache Fallback-Formatierung, falls keine HTML-Daten vorhanden sind.
    static func formatPrice(_ price: String, currencySymbol: String = "€") -> String {
        if price.contains(currencySymbol) {
            return price
        }
        return "\(price)\(currencySymbol)"
    }
    
    /// Parst die `price_html` von WooCommerce.
    static func formatPriceString(from htmlString: String?, fallbackPrice: String, currencySymbol: String = "€") -> FormattedPrice {
        guard let html = htmlString, !html.isEmpty else {
            return FormattedPrice(display: formatPrice(fallbackPrice, currencySymbol: currencySymbol), strikethrough: nil)
        }

        let delRegex = Regex {
            "<del>"
            Capture { OneOrMore(.any, .reluctant) }
            "</del>"
        }
        
        let insRegex = Regex {
            "<ins>"
            Capture { OneOrMore(.any, .reluctant) }
            "</ins>"
        }
        
        var salePrice: String?
        var regularPrice: String?

        if let saleMatch = html.firstMatch(of: insRegex)?.1, let delMatch = html.firstMatch(of: delRegex)?.1 {
            salePrice = String(saleMatch).strippingHTML()
            regularPrice = String(delMatch).strippingHTML()
        } else {
            let cleanPrice = html.strippingHTML()
            salePrice = cleanPrice
        }
        
        let finalDisplayPrice = formatPrice(salePrice ?? fallbackPrice, currencySymbol: currencySymbol)
        let finalStrikethroughPrice = regularPrice != nil ? formatPrice(regularPrice!, currencySymbol: currencySymbol) : nil

        return FormattedPrice(display: finalDisplayPrice, strikethrough: finalStrikethroughPrice)
    }
    
    /// **DIESE FUNKTION HAT GEFEHLT:**
    /// Berechnet eine Preisspanne aus einer Liste von Variationen.
    static func calculatePriceRange(from variations: [WooCommerceProductVariation], currencySymbol: String = "€") -> String? {
        let prices = variations.compactMap { Double($0.price) }
        
        guard let minPrice = prices.min(), let maxPrice = prices.max() else {
            return nil
        }
        
        guard minPrice != maxPrice else {
            return nil
        }
        
        let minFormatted = String(format: "%.2f", minPrice)
        let maxFormatted = String(format: "%.2f", maxPrice)
        
        return "\(minFormatted)\(currencySymbol) - \(maxFormatted)\(currencySymbol)"
    }
}
