import SwiftUI

struct AuthContainerView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager
    
    @State private var currentAuthView: AuthState = .login
    
    enum AuthState {
        case login
        case signUp
    }

    var onDismiss: () -> Void // Um das Sheet zu schließen, wenn erfolgreich

    var body: some View {
        NavigationView { // Optional, für einen Titel in den Auth-Views
            Group {
                if currentAuthView == .login {
                    LoginView(
                        onLoginSuccess: {
                            // authManager.user wird durch Listener aktualisiert
                            // das onReceive in LoginView sollte onDismiss aufrufen
                        },
                        navigateToSignUp: { currentAuthView = .signUp }
                    )
                } else {
                    SignUpView(
                        onSignUpSuccess: {
                           // authManager.user wird durch Listener aktualisiert
                        },
                        navigateToLogin: { currentAuthView = .login }
                    )
                }
            }
            // Hier könnten NavigationBarItems für Abbrechen etc. hin
        }
        .onReceive(authManager.$user) { user in
            if user != nil {
                onDismiss() // Schließe das Auth-Sheet, wenn der Nutzer angemeldet ist
            }
        }
    }
}
