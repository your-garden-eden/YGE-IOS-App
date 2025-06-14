// Path: Your-Garden-Eden-IOS/Core/Extensions/String+Extensions.swift

import Foundation

extension String {
    
    /// Wandelt einen HTML-String sicher in einen reinen Text-String um.
    func strippingHTML() -> String {
        guard !self.isEmpty,
              let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func asURL() -> URL? {
        return URL(string: self)
    }
    
    func slugify() -> String {
        return self.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}
