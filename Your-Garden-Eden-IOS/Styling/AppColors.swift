import SwiftUI

struct AppColors {
    static let primary: Color = Color(hex: "#A1B48A")
    static let primaryDark: Color = Color(hex: "#798C67")
    static let primaryLight: Color = Color(hex: "#c8d4ba")
    static let textOnPrimary: Color = Color(hex: "#FFFFFF")

    static let secondary: Color = Color(hex: "#4E342E")
    
    static let textBase: Color = Color(hex: "#333333")
    static let textMuted: Color = Color(hex: "#6c757d")
    static let textHeadings: Color = secondary
    static let textLink: Color = primary

    static let backgroundPage: Color = Color(hex: "#F5F0E0")
    static let backgroundComponent: Color = Color(hex: "#FFFFFF")
    static let backgroundLightGray: Color = Color(hex: "#f8f9fa")

    static let success: Color = Color(hex: "#28a745")
    static let error: Color = Color(hex: "#dc3545")
    static let price: Color = Color(hex: "#2e6b2e")
    static let borderLight: Color = Color(hex: "#eeeeee")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
