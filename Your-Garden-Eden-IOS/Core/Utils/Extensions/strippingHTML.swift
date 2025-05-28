import Foundation
// YGE-IOS-App/Core/Utilities/Extensions/String+Extensions.swift
// (oder ein anderer passender Ort für deine Extensions)

extension String {
    func strippingHTML() -> String {
        // Diese Regular Expression versucht, HTML-Tags zu entfernen.
        // Es ist eine einfache Implementierung und könnte für sehr komplexes HTML ggf. nicht perfekt sein.
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
