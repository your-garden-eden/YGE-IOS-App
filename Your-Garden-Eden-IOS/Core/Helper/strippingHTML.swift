// DATEI: String+Utilities.swift
// PFAD: Core/Utilities/Extensions/String+Utilities.swift
// STATUS: GEPRÜFT & BESTÄTIGT

import Foundation
import RegexBuilder

public extension String {
    
    func strippingHTML() -> String {
        guard !self.isEmpty else { return "" }
        let cleanedString = self.replacingOccurrences(of: " ", with: " ")
        if #available(iOS 16.0, *) {
            let htmlTagRegex = /<[^>]+>/
            return cleanedString.replacing(htmlTagRegex, with: "")
        } else {
            return cleanedString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        }
    }
    
    func asURL() -> URL? {
        return URL(string: self)
    }
    
    func slugify() -> String {
        let baseString = self.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        if #available(iOS 16.0, *) {
            let invalidCharsRegex = /[^a-z0-9-]+/
            let spacesToDashRegex = /\s+/
            return baseString
                .replacing(spacesToDashRegex, with: "-")
                .replacing(invalidCharsRegex, with: "")
        } else {
            let invalidChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-").inverted
            return baseString
                .components(separatedBy: .whitespacesAndNewlines).joined(separator: "-")
                .components(separatedBy: invalidChars).joined()
        }
    }
}
