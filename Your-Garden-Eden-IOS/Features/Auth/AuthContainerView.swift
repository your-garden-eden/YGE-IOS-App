import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var currentAuthView: AuthState = .login
    
    enum AuthState {
        case login, signUp
    }

    var onDismiss: () -> Void

    var body: some View {
        // Die untergeordneten Views (LoginView, SignUpView) bringen ihre eigene NavigationStack mit.
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
