import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager // Zugriff auf den AuthManager
    @State private var email = ""
    @State private var password = ""

    var onLoginSuccess: () -> Void // Callback, um z.B. ein Sheet zu schließen
    var navigateToSignUp: () -> Void // Callback, um zur Registrierungsansicht zu wechseln

    var body: some View {
        VStack(spacing: 20) {
            Text("Willkommen zurück!")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("E-Mail", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            SecureField("Passwort", text: $password)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            if authManager.isLoading {
                ProgressView()
            } else {
                Button("Anmelden") {
                    authManager.signInWithEmail(email: email, password: password)
                    // onLoginSuccess wird implizit durch den AuthStateChangeListener im authManager getriggert,
                    // wenn wir das hier als Sheet präsentieren. Alternativ expliziter Aufruf nach Erfolg.
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(email.isEmpty || password.isEmpty)
            }
            
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("Noch kein Konto? Registrieren") {
                navigateToSignUp()
            }
            .padding(.top)

            // Später: Google Sign-In Button
            // Button("Mit Google anmelden") {
            //    authManager.signInWithGoogle()
            // }
            // .padding()
            // ...

            Spacer()
        }
        .padding()
        // .navigationTitle("Anmelden") // Falls in einer NavigationView
        .onReceive(authManager.$user) { user in
             if user != nil {
                 onLoginSuccess() // Rufe Callback auf, wenn Nutzer erfolgreich angemeldet ist
             }
        }
    }
}

// Preview (optional, aber hilfreich)
// struct LoginView_Previews: PreviewProvider {
//     static var previews: some View {
//         LoginView(onLoginSuccess: {}, navigateToSignUp: {})
//             .environmentObject(FirebaseAuthManager()) // Mock oder echter Manager für Preview
//     }
// }
