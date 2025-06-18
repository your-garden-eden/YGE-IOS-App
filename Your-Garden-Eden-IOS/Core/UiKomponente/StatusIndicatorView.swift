//
//  StatusIndicatorView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: StatusIndicatorView.swift
// PFAD: Core/UI/Components/StatusIndicatorView.swift
// ZWECK: Eine wiederverwendbare Komponente zur Anzeige von verschiedenen Zuständen
//        (z.B. Fehler, Erfolg, Information) als vollflächige Ansicht oder als schwebendes Banner.

import SwiftUI

/// Eine vielseitige Ansicht zur Anzeige von Statusmeldungen.
struct StatusIndicatorView: View {
    
    /// Definiert den Stil und Inhalt der Anzeige.
    enum Style {
        case error(message: String)
        case success(message: String)
        
        var message: String {
            switch self {
            case .error(let message): return message
            case .success(let message): return message
            }
        }
        
        var iconName: String {
            switch self {
            case .error: return "exclamationmark.triangle.fill"
            case .success: return "checkmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .error: return AppTheme.Colors.error
            case .success: return AppTheme.Colors.success
            }
        }
    }
    
    /// Definiert die Darstellungsart.
    enum DisplayMode {
        /// Ein schwebendes Banner am oberen oder unteren Bildschirmrand.
        case banner
        /// Eine zentrierte Vollbild-Ansicht.
        case fullScreen
    }
    
    let style: Style
    let displayMode: DisplayMode
    
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

// MARK: - Convenience Initializer
// Diese ermöglichen die alte, einfache Syntax beizubehalten, während intern die neue, flexible Struktur genutzt wird.

extension StatusIndicatorView {
    /// Initializer für eine einfache Vollbild-Fehleransicht.
    static func errorState(message: String) -> some View {
        StatusIndicatorView(style: .error(message: message), displayMode: .fullScreen)
    }
    
    /// Initializer für ein einfaches Erfolgs-Banner.
    static func successBanner(message: String) -> some View {
        StatusIndicatorView(style: .success(message: message), displayMode: .banner)
    }
    
    /// Initializer für ein einfaches Fehler-Banner.
    static func errorBanner(message: String) -> some View {
        StatusIndicatorView(style: .error(message: message), displayMode: .banner)
    }
}