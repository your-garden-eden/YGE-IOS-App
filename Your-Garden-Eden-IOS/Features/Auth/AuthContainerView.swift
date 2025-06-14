// Path: Your-Garden-Eden-IOS/Features/Auth/AuthContainerView.swift

import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var currentAuthView: AuthState = .login
    
    enum AuthState {
        case login, signUp
    }

    var onDismiss: () -> Void

    var body: some View {
        // Kein NavigationStack hier, da die untergeordneten Views ihn bereitstellen
        Group {
            if currentAuthView == .login {
                LoginView(
                    onDismiss: onDismiss,
                    navigateToSignUp: { withAnimation { currentAuthView = .signUp } }
                )
            } else {
                SignUpView(
                    onDismiss: onDismiss,
                    navigateToLogin: { withAnimation { currentAuthView = .login } }
                )
            }
        }
        .environmentObject(authManager)
    }
}
