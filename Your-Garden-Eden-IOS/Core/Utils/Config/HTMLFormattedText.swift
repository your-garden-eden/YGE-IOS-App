//
//  HTMLFormattedText.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 06.06.25.
//


import SwiftUI

/// Eine View, die einen HTML-String entgegennimmt und ihn als formatierten
/// Text in SwiftUI darstellt. Sie kümmert sich um die Konvertierung von
/// HTML-Tags und Zeichen-Codes (wie €, •, etc.).
struct HTMLFormattedText: View {
    let htmlString: String
    
    // Interne Darstellung als AttributedString
    private let attributedString: NSAttributedString
    
    init(_ htmlString: String) {
        self.htmlString = htmlString
        
        // Versuche, den HTML-String zu parsen.
        guard let data = htmlString.data(using: .utf8) else {
            self.attributedString = NSAttributedString(string: htmlString)
            return
        }
        
        if let attrString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
            self.attributedString = attrString
        } else {
            self.attributedString = NSAttributedString(string: htmlString)
        }
    }
    
    var body: some View {
        // SwiftUI kann einen AttributedString direkt in einem Text-Element darstellen.
        Text(AttributedString(attributedString))
    }
}