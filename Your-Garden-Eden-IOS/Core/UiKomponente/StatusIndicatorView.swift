// DATEI: StatusIndicatorView.swift
// PFAD: Core/UI/Components/StatusIndicatorView.swift
// ÄNDERUNG: Die lokalen Enums wurden ausgelagert. Die View nutzt nun die
//           globalen Enums `StatusIndicatorStyle` und `StatusIndicatorDisplayMode`.

import SwiftUI

struct StatusIndicatorView: View {
    
    // Die lokalen Enum-Definitionen wurden entfernt.
    
    // ANPASSUNG: Nutzt die globalen Enums.
    let style: StatusIndicatorStyle
    let displayMode: StatusIndicatorDisplayMode
    
    var body: some View {
        switch displayMode {
        case .banner:
            bannerView
        case .fullScreen:
            fullScreenView
        }
    }
    
    private var bannerView: some View {
        HStack(spacing: AppTheme.Layout.Spacing.small) {
            Image(systemName: style.iconName)
            Text(style.message)
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.subheadline, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(style.color)
        .foregroundColor(AppTheme.Colors.textOnPrimary)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.medium)
        .padding(.horizontal)
    }
    
    private var fullScreenView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            Image(systemName: style.iconName)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(style.color)
            
            Text(style.message)
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Convenience Initializer bleiben funktional, verweisen nun aber intern auf die neuen Enums.
extension StatusIndicatorView {
    static func errorState(message: String) -> some View {
        StatusIndicatorView(style: .error(message: message), displayMode: .fullScreen)
    }
    
    static func successBanner(message: String) -> some View {
        StatusIndicatorView(style: .success(message: message), displayMode: .banner)
    }
    
    static func errorBanner(message: String) -> some View {
        StatusIndicatorView(style: .error(message: message), displayMode: .banner)
    }
}
