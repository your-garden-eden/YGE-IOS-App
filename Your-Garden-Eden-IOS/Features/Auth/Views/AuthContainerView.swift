// Dateiname: Features/Auth/AuthContainerView.swift

import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var currentAuthView: AuthState = .login
    
    enum AuthState {
        case login
        case signUp
    }

    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if currentAuthView == .login {
                    LoginView(
                        onDismiss: { onDismiss() },
                        navigateToSignUp: { currentAuthView = .signUp }
                    )
                } else {
                    SignUpView(
                        onDismiss: { onDismiss() },
                        navigateToLogin: { currentAuthView = .login }
                    )
                }
            }
        }
        .environmentObject(authManager)
    }
}
