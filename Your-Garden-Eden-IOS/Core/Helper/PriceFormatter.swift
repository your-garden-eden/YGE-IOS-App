
// DATEI: PriceFormatter.swift
// PFAD: Core/Utilities/PriceFormatter.swift
// VERSION: 2.2 (FINAL KORRIGIERT & VOLLSTÄNDIG)
// STATUS: Fehlende Funktion wiederhergestellt.

import Foundation

public struct PriceFormatter {
    
    public struct FormattedPrice {
        public let display: String
        public let strikethrough: String?
    }
    
    public static func formatDisplayPrice(for product: WooCommerceProduct) -> FormattedPrice {
        if product.onSale == true, let saleValue = Double(product.salePrice), saleValue > 0, let regularValue = Double(product.regularPrice), regularValue > saleValue {
            return FormattedPrice(display: formatCurrency(value: saleValue), strikethrough: formatCurrency(value: regularValue))
        }
        if let priceValue = Double(product.price), priceValue > 0 {
            return FormattedPrice(display: formatCurrency(value: priceValue), strikethrough: nil)
        }
        if let priceHtml = product.priceHTML, !priceHtml.isEmpty {
            return formatPriceStringFromHtml(html: priceHtml)
        }
        return FormattedPrice(display: "Auf Anfrage", strikethrough: nil)
    }

    public static func formatVariationPrice(_ variation: WooCommerceProductVariation) -> FormattedPrice {
        let salePrice = Double(variation.sale_price) ?? 0.0
        let regularPrice = Double(variation.regular_price) ?? 0.0
        let displayPrice = Double(variation.price) ?? 0.0
        if salePrice > 0 && regularPrice > salePrice {
            return FormattedPrice(display: formatCurrency(value: salePrice), strikethrough: formatCurrency(value: regularPrice))
        }
        return FormattedPrice(display: formatCurrency(value: displayPrice), strikethrough: nil)
    }
    
    // --- WIEDERHERGESTELLTE FUNKTION ---
    public static func calculatePriceRange(from variations: [WooCommerceProductVariation]) -> String? {
        let prices = variations.compactMap { Double($0.price) }
        guard let minPrice = prices.min(), let maxPrice = prices.max(), minPrice != maxPrice else { return nil }
        // Format as a simple string, to be parsed later
        return "\(minPrice)-\(maxPrice)"
    }
    
    private static func formatPriceStringFromHtml(html: String) -> FormattedPrice {
        let cleanHtml = html.strippingHTML()
        let priceRegex = /([0-9]+(?:[.,][0-9]+)?)/
        let matches = cleanHtml.matches(of: priceRegex)
        let prices = matches.compactMap { Double(String($0.output.1).replacingOccurrences(of: ",", with: ".")) }.sorted()
        
        if prices.count >= 2 {
            let min = prices[0]
            let max = prices[prices.count - 1]
            if min != max {
                 return FormattedPrice(display: "\(formatCurrency(value: min)) – \(formatCurrency(value: max))", strikethrough: nil)
            } else {
                 return FormattedPrice(display: formatCurrency(value: min), strikethrough: nil)
            }
        } else if let price = prices.first {
            return FormattedPrice(display: formatCurrency(value: price), strikethrough: nil)
        }
        
        return FormattedPrice(display: "Auf Anfrage", strikethrough: nil)
    }
    
    public static func formatPriceFromMinorUnit(value: String?, minorUnit: Int) -> String {
        guard let valueString = value, let intValue = Int(valueString) else {
            return formatCurrency(value: 0.0)
        }
        let doubleValue = Double(intValue) / pow(10, Double(minorUnit))
        return formatCurrency(value: doubleValue)
    }
    
    public static func formatCurrency(value: Double, symbol: String = "€") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: NSNumber(value: value)) ?? "\(String(format: "%.2f", value)) \(symbol)"
    }
}

