import SwiftUI

struct AppStyles {
    struct Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
    }

    struct BorderRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
    }

    struct Shadows {
        static let small = ShadowStyle(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        static let medium = ShadowStyle(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
        
        struct ShadowStyle {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }
    }
}

extension View {
    func appShadow(_ style: AppStyles.Shadows.ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .bold))
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? AppColors.primaryDark : AppColors.primary)
            .foregroundColor(AppColors.textOnPrimary)
            .cornerRadius(AppStyles.BorderRadius.large)
            .appShadow(AppStyles.Shadows.small)
    }
}
