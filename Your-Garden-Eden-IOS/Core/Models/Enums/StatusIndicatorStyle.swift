//
//  StatusIndicatorStyle.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 20.06.25.
//


// DATEI: StatusIndicatorEnums.swift
// PFAD: Enums/StatusIndicatorEnums.swift
// ZWECK: Definiert die Konfigurationsoptionen für die StatusIndicatorView-Komponente.

import SwiftUI

/// Definiert den Stil und die semantische Bedeutung einer Statusmeldung.
public enum StatusIndicatorStyle {
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

/// Definiert die Darstellungsart des Status-Indikators.
public enum StatusIndicatorDisplayMode {
    /// Ein schwebendes Banner am Bildschirmrand.
    case banner
    /// Eine zentrierte Vollbild-Ansicht.
    case fullScreen
}