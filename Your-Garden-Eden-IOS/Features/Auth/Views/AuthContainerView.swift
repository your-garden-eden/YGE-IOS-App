// DATEI: AuthContainerView.swift
// PFAD: Features/Auth/Views/AuthContainerView.swift
// VERSION: ADLERAUGE 1.1
// STATUS: KORRIGIERT & STABILISIERT

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
        // --- BEGINN MODIFIKATION ---
        // KORREKTUR: Beobachtet nun den korrekten Publisher `$authState`.
        .onReceive(authManager.$authState) { newState in
            // Wenn der Benutzer sich erfolgreich einloggt (Zustand wechselt zu .authenticated),
            // wird das gesamte Sheet geschlossen.
            if newState == .authenticated {
                onDismiss()
            }
        }
        // --- ENDE MODIFIKATION ---
    }
}
