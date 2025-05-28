//
//  AppStyles.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//


// Ressourcen/Styling/AppStyles.swift

import SwiftUI // oder import CoreGraphics für CGFloat

struct AppStyles {

    struct Spacing {
        static let xxSmall: CGFloat = 2
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12 // Entspricht --spacing-md aus SCSS (1.5 * 8px)
        static let large: CGFloat = 16  // Entspricht --spacing-lg aus SCSS (2 * 8px)
        static let xLarge: CGFloat = 24 // Entspricht --spacing-xl aus SCSS (3 * 8px)
        static let xxLarge: CGFloat = 32 // Entspricht --spacing-xxl aus SCSS (4 * 8px)
        static let xxxLarge: CGFloat = 48// Entspricht --spacing-xxxl aus SCSS (6 * 8px)
    }

    struct BorderRadius {
        static let small: CGFloat = 3   // --border-radius-sm
        static let medium: CGFloat = 5  // --border-radius-md
        static let large: CGFloat = 8   // --border-radius-lg
        static let pill: CGFloat = 50 * 16 // Annahme für 50rem basierend auf 16px root, anpassen falls nötig
        static let circle: CGFloat = .infinity // Für perfekte Kreise bei quadratischen Elementen
    }

    struct Shadows {
        static let small = ShadowStyle(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        static let medium = ShadowStyle(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4, secondaryColor: Color.black.opacity(0.06), secondaryRadius: 4, secondaryX: 0, secondaryY: 2)
        static let large = ShadowStyle(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10, secondaryColor: Color.black.opacity(0.05), secondaryRadius: 6, secondaryX: 0, secondaryY: 4)

        struct ShadowStyle { // Hilfsstruktur für komplexere Schatten
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
            var secondaryColor: Color? = nil
            var secondaryRadius: CGFloat? = nil
            var secondaryX: CGFloat? = nil
            var secondaryY: CGFloat? = nil
        }
    }
    
    // Hier könnten auch Z-Indizes als statische Double-Werte definiert werden, falls benötigt.
    // struct ZIndex {
    //     static let dropdown: Double = 1000
    //     // ...
    // }
}

// ViewModifier für die Schatten, um die Anwendung zu vereinfachen
extension View {
    func appShadow(_ style: AppStyles.Shadows.ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
            .if(style.secondaryColor != nil && style.secondaryRadius != nil && style.secondaryX != nil && style.secondaryY != nil) { view in
                view.shadow(color: style.secondaryColor!, radius: style.secondaryRadius!, x: style.secondaryX!, y: style.secondaryY!)
            }
    }
}

// Hilfs-ViewModifier für bedingte Modifikationen
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}