//
//  AuthContainerView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: AuthContainerView.swift
// PFAD: Features/Auth/Views/AuthContainerView.swift
// ZWECK: Dient als zentraler Einstiegspunkt und Navigations-Host für den
//        gesamten Authentifizierungs-Flow (Login, Registrierung, etc.).

import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var onDismiss: () -> Void

    var body: some View {
        // Dieser Container ist der alleinige Besitzer des NavigationStack.
        NavigationStack {
            LoginView()
        }
        .environmentObject(authManager)
        .onReceive(authManager.$isLoggedIn) { isLoggedIn in
            // Wenn der Benutzer sich erfolgreich einloggt, wird das gesamte Sheet geschlossen.
            if isLoggedIn {
                onDismiss()
            }
        }
    }
}