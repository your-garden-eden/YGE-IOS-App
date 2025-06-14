// Path: Your-Garden-Eden-IOS/Core/Helpers/PriceFormatter.swift

import Foundation

struct PriceFormatter {

    struct FormattedPrice {
        let display: String
        let strikethrough: String?
    }

    static func formatPrice(_ priceString: String?, currencySymbol: String) -> String {
        guard let validPriceString = priceString?.trimmingCharacters(in: .whitespacesAndNewlines), !validPriceString.isEmpty else { return "" }
        
        let numberString = validPriceString.replacingOccurrences(of: ",", with: ".")
        guard let priceNumber = Double(numberString) else {
            return "\(validPriceString)\(currencySymbol)"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        
        if let formattedNumber = formatter.string(from: NSNumber(value: priceNumber)) {
            return "\(formattedNumber) \(currencySymbol)"
        } else {
            return "\(validPriceString) \(currencySymbol)"
        }
    }

    static func formatPriceString(from htmlString: String?, fallbackPrice: String, currencySymbol: String) -> FormattedPrice {
        guard let validString = htmlString, !validString.isEmpty else {
            let formattedFallback = formatPrice(fallbackPrice, currencySymbol: currencySymbol)
            return FormattedPrice(display: formattedFallback, strikethrough: nil)
        }

        if let salePrice = extractPricesWithRegex(from: validString, currencySymbol: currencySymbol) {
            return salePrice
        }
        
        let plainString = validString.strippingHTML()
        if plainString.contains("–") {
            let components = plainString.components(separatedBy: "–").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if let firstPrice = components.first, !firstPrice.isEmpty {
                return FormattedPrice(display: "Ab \(firstPrice)", strikethrough: nil)
            }
        }
        
        return FormattedPrice(display: plainString, strikethrough: nil)
    }
    
    private static func extractPricesWithRegex(from html: String, currencySymbol: String) -> FormattedPrice? {
        let regex = try! NSRegularExpression(pattern: "[0-9.,]+")
        let results = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        let prices = results.map { String(html[Range($0.range, in: html)!]) }

        switch prices.count {
        case 2:
            let strikethroughPrice = formatPrice(prices[0], currencySymbol: currencySymbol)
            let displayPrice = formatPrice(prices[1], currencySymbol: currencySymbol)
            return FormattedPrice(display: displayPrice, strikethrough: strikethroughPrice)
        case 1:
            let displayPrice = formatPrice(prices[0], currencySymbol: currencySymbol)
            return FormattedPrice(display: displayPrice, strikethrough: nil)
        default:
            return nil
        }
    }
}
