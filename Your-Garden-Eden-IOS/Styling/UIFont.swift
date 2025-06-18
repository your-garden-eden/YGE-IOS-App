// DATEI: UIFont+Extensions.swift
// PFAD: Core/UI/Extensions/UIFont+Extensions.swift
// ZWECK: Stellt eine Hilfserweiterung für `UIFont` bereit, um Schriftarten konsistent
//        mit dem App-Design zu laden. Notwendig für UIKit-basierte Berechnungen.

import UIKit

internal extension UIFont {
    /// Lädt die "Roboto"-Schriftart in der angegebenen Größe und Gewichtung.
    /// Stellt einen Fallback auf die System-Schriftart sicher, falls die benutzerdefinierte Schrift nicht geladen werden kann.
    static func roboto(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String
        switch weight {
        case .bold: fontName = "Roboto-Bold"
        case .medium: fontName = "Roboto-Medium"
        default: fontName = "Roboto-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
