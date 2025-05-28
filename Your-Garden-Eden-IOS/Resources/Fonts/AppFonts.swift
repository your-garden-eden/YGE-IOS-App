// Ressourcen/Styling/AppFonts.swift

import SwiftUI

struct AppFonts {

    // ... (Family Struktur bleibt gleich) ...
    struct Family {
        static let montserrat = "Montserrat"
        static let roboto = "Roboto"
    }


    struct Weight {
        static let light = Font.Weight.light
        static let regular = Font.Weight.regular // KORREKT: .regular für normal
        static let medium = Font.Weight.medium
        static let semibold = Font.Weight.semibold
        static let bold = Font.Weight.bold
    }

    // ... (Size Struktur bleibt gleich) ...
    struct Size {
        static let caption: CGFloat = 12
        static let smallBody: CGFloat = 14
        static let body: CGFloat = 16
        static let mediumBody: CGFloat = 18
        static let largeBody: CGFloat = 20
        static let h6: CGFloat = 20
        static let h5: CGFloat = 22
        static let h4: CGFloat = 24
        static let h3: CGFloat = 28
        static let h2: CGFloat = 32
        static let h1: CGFloat = 36
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let headline: CGFloat = 17
        static let title3: CGFloat = 20
        static let title2: CGFloat = 22
        static let title1: CGFloat = 28
        static let largeTitle: CGFloat = 34
    }


    static func montserrat(size: CGFloat, weight: Font.Weight = .regular) -> Font { // Default auf .regular
        return .custom(Family.montserrat, size: size).weight(weight)
    }

    static func roboto(size: CGFloat, weight: Font.Weight = .regular) -> Font { // Default auf .regular
        return .custom(Family.roboto, size: size).weight(weight)
    }
}
