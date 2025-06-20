// DATEI: String+Utilities.swift
// PFAD: Helper/String+Utilities.swift
// VERSION: FINAL - Alle Operationen integriert.

import Foundation
import RegexBuilder

public extension String {
    
    func strippingHTML() -> String {
        let cleanedString = self
            .replacingOccurrences(of: " ", with: " ")
            .replacingOccurrences(of: "€", with: "€")
        
        let htmlTagRegex = /<.*?>/
        return cleanedString.replacing(htmlTagRegex, with: "")
    }
    
    func asURL() -> URL? {
        return URL(string: self)
    }
    
    func slugify() -> String {
        let baseString = self.folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()

        let invalidCharsRegex = /[^a-z0-9-]+/
        let spacesToDashRegex = /\s+/
        
        let processedString = baseString
            .replacing(spacesToDashRegex, with: "-")
            .replacing(invalidCharsRegex, with: "")
            
        return processedString
    }
}
