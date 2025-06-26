// DATEI: AppTheme.swift
// PFAD: Core/UI/AppTheme.swift
// VERSION: 1.4 (ANGEPASST)
// STATUS: Fehlender Button-Stil hinzugefügt.

import SwiftUI

public enum AppTheme {

    public struct Colors {
        public static let primary: Color = Color(hex: "#A1B48A")
        public static let primaryDark: Color = Color(hex: "#798C67")
        public static let primaryLight: Color = Color(hex: "#c8d4ba")
        public static let textOnPrimary: Color = Color(hex: "#FFFFFF")

        public static let secondary: Color = Color(hex: "#4E342E")
        
        public static let textBase: Color = Color(hex: "#333333")
        public static let textMuted: Color = Color(hex: "#6c757d")
        public static let textHeadings: Color = secondary
        public static let textLink: Color = primary

        public static let backgroundPage: Color = Color(hex: "#F5F0E0")
        public static let backgroundComponent: Color = Color(hex: "#FFFFFF")
        public static let backgroundLightGray: Color = Color(hex: "#f8f9fa")

        public static let success: Color = Color(hex: "#28a745")
        public static let error: Color = Color(hex: "#dc3545")
        public static let price: Color = Color(hex: "#2e6b2e")
        public static let borderLight: Color = Color(hex: "#eeeeee")
    }

    public struct Fonts {
        public struct Family {
            public static let montserrat = "Montserrat"
            public static let roboto = "Roboto"
        }

        public struct Weight {
            public static let regular = Font.Weight.regular
            public static let medium = Font.Weight.medium
            public static let semibold = Font.Weight.semibold
            public static let bold = Font.Weight.bold
        }

        public struct Size {
            public static let caption: CGFloat = 12
            public static let body: CGFloat = 16
            public static let subheadline: CGFloat = 15
            public static let headline: CGFloat = 17
            public static let h6: CGFloat = 20
            public static let h5: CGFloat = 22
            public static let h4: CGFloat = 24
            public static let h3: CGFloat = 28
            public static let h2: CGFloat = 32
            public static let h1: CGFloat = 36
            public static let title2: CGFloat = 22
        }

        public static func montserrat(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            return .custom(Family.montserrat, size: size).weight(weight)
        }

        public static func roboto(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            return .custom(Family.roboto, size: size).weight(weight)
        }
    }
    
    public struct Layout {
        public struct Spacing {
            public static let xSmall: CGFloat = 4
            public static let small: CGFloat = 8
            public static let medium: CGFloat = 12
            public static let large: CGFloat = 16
            public static let xLarge: CGFloat = 24
            public static let xxLarge: CGFloat = 32
        }

        public struct BorderRadius {
            public static let small: CGFloat = 4
            public static let medium: CGFloat = 8
            public static let large: CGFloat = 12
        }
    }

    public struct Shadows {
        public static let small = ShadowStyle(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        public static let medium = ShadowStyle(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
        
        public struct ShadowStyle {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }
    }
    
    public struct PrimaryButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body, weight: .bold))
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(configuration.isPressed ? AppTheme.Colors.primaryDark : AppTheme.Colors.primary)
                .foregroundColor(AppTheme.Colors.textOnPrimary)
                .cornerRadius(AppTheme.Layout.BorderRadius.large)
                .appShadow(AppTheme.Shadows.small)
        }
    }
    
    // ===================================================================
    // === BEGINN KORREKTUR #8                                         ===
    // ===================================================================
    // HINZUGEFÜGT: Fehlender ButtonStyle für den Gutschein-Button.
    public struct SecondaryButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .semibold))
                .padding(.horizontal, AppTheme.Layout.Spacing.large)
                .frame(height: 44)
                .background(configuration.isPressed ? AppTheme.Colors.primary.opacity(0.2) : AppTheme.Colors.primary.opacity(0.1))
                .foregroundColor(AppTheme.Colors.primaryDark)
                .cornerRadius(AppTheme.Layout.BorderRadius.medium)
        }
    }
    // ===================================================================
    // === ENDE KORREKTUR #8                                           ===
    // ===================================================================
   
    public struct PlainTextFieldStyle: TextFieldStyle {
        public func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding()
                .background(Colors.backgroundComponent)
                .cornerRadius(Layout.BorderRadius.large)
                .shadow(color: Shadows.small.color, radius: Shadows.small.radius, x: Shadows.small.x, y: Shadows.small.y)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.BorderRadius.large)
                        .stroke(Colors.borderLight, lineWidth: 1)
                )
        }
    }
}

public extension View {
    func appShadow(_ style: AppTheme.Shadows.ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
