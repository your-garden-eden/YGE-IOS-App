// DATEI: AppTheme.swift (KASERNE DER ÄSTHETIK)
// VERSION: GUTSCHEIN 1.1 (OPERATION FRONTBEGRADIGUNG)
// ZWECK: Zentralisiert alle Design-Konstanten und Stile der Anwendung.
// ÄNDERUNG: PlainTextFieldStyle und SecondaryButtonStyle hinzugefügt, um Kompilierungsfehler in CartView zu beheben und die UI zu vereinheitlichen.

import SwiftUI

/// Dient als zentraler Namespace für alle Design-Elemente der App, um eine klare Struktur und einfache Handhabung zu gewährleisten.
public enum AppTheme {

    // MARK: - Farben (Farbpalette)
    /// Definiert die gesamte Farbpalette der Anwendung. Jede Farbe hat einen spezifischen semantischen Zweck.
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

    // MARK: - Schriften (Typografie-Kodex)
    /// Definiert die typografischen Regeln der Anwendung, einschließlich Schriftfamilien, -gewichten, -größen und Helferfunktionen.
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
    
    // MARK: - Layout (Strukturvorgaben)
    /// Definiert Standardwerte für Layout-Elemente wie Abstände und Eckenradien.
    public struct Layout {
        /// Standardisierte Abstände für Padding und Margins in der gesamten App.
        public struct Spacing {
            public static let xSmall: CGFloat = 4
            public static let small: CGFloat = 8
            public static let medium: CGFloat = 12
            public static let large: CGFloat = 16
            public static let xLarge: CGFloat = 24
            public static let xxLarge: CGFloat = 32
        }

        /// Standardisierte Eckenradien für UI-Elemente wie Buttons und Karten.
        public struct BorderRadius {
            public static let small: CGFloat = 4
            public static let medium: CGFloat = 8
            public static let large: CGFloat = 12
        }
    }

    // MARK: - Schatten (Tiefenwirkung)
    /// Definiert vordefinierte Schattenstile für eine konsistente Tiefenwirkung der Benutzeroberfläche.
    public struct Shadows {
        public static let small = ShadowStyle(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        public static let medium = ShadowStyle(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
        
        /// Beschreibt die Eigenschaften eines einzelnen Schattenstils.
        public struct ShadowStyle {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }
    }
    
    // MARK: - Komponenten-Stile (Uniformen)
    
    /// Definiert den Standard-Stil für primäre Aktions-Buttons in der App.
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
    
    // === BEGINN MODIFIKATION ===
    // NEU: Definiert den Stil für sekundäre oder weniger prominente Buttons.
    public struct SecondaryButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .semibold))
                .padding(.horizontal)
                .frame(height: 44)
                .background(configuration.isPressed ? AppTheme.Colors.backgroundLightGray : AppTheme.Colors.backgroundComponent)
                .foregroundColor(AppTheme.Colors.primaryDark)
                .cornerRadius(AppTheme.Layout.BorderRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.BorderRadius.medium)
                        .stroke(AppTheme.Colors.borderLight, lineWidth: 1)
                )
        }
    }

    // NEU: Definiert einen sauberen Stil für Texteingabefelder.
    public struct PlainTextFieldStyle: TextFieldStyle {
        public func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                .padding(.horizontal, AppTheme.Layout.Spacing.medium)
                .frame(height: 44)
                .background(AppTheme.Colors.backgroundComponent)
                .cornerRadius(AppTheme.Layout.BorderRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.BorderRadius.medium)
                        .stroke(AppTheme.Colors.borderLight, lineWidth: 1)
                )
        }
    }
    // === ENDE MODIFIKATION ===
    
    /// Definiert den Stil für kleine, runde Buttons zur Mengenänderung (z.B. im Warenkorb).
    public struct QuantityButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 30, height: 30)
                .background(AppTheme.Colors.primary.opacity(configuration.isPressed ? 0.2 : 0.1))
                .clipShape(Circle())
        }
    }
}

// MARK: - Hilfserweiterungen (Werkzeuge)

/// Eine Erweiterung für `View`, um das Anwenden von vordefinierten Schatten zu vereinfachen.
public extension View {
    func appShadow(_ style: AppTheme.Shadows.ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

/// Eine Erweiterung für `Color`, um die Initialisierung mit Hex-Farbwerten zu ermöglichen.
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
