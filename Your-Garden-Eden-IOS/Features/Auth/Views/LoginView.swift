// Your-Garden-Eden-IOS/Features/Auth/Views/LoginView.swift (Auszug und Anpassung)

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager // Korrekt

    @State private var email = ""
    @State private var password = ""

    // Optional: Lokaler State für UI-spezifische Validierungsfehler
    @State private var validationError: String?

    var onLoginSuccess: () -> Void   // Callback für erfolgreichen Login (um Sheet zu schließen)
    var navigateToSignUp: () -> Void // Callback, um zur SignUpView zu wechseln

    var body: some View {
        VStack(spacing: 15) {
            Text("Willkommen zurück!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            TextField("E-Mail", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            SecureField("Passwort", text: $password)
                .textContentType(.password) // .password für existierende Passwörter
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            // Fehleranzeige
            // Zuerst lokale Validierungsfehler anzeigen
            if let validationError = validationError {
                Text(validationError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
            }
            // Dann Fehler vom AuthManager anzeigen (Zeile ~45)
            else if let authError = authManager.authError { // <-- HIER DIE ÄNDERUNG: authError statt errorMessage
                Text(authError.localizedDescription) // Verwende .localizedDescription für die Anzeige
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
            }

            Button(action: {
                // Validierung und Login-Aktion
                validationError = nil
                // authManager.authError = nil // Wird im AuthManager selbst zurückgesetzt

                guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
                    validationError = "Bitte E-Mail und Passwort eingeben."
                    return
                }
                
                guard isValidEmail(email.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                    validationError = "Bitte eine gültige E-Mail-Adresse eingeben."
                    return
                }

                authManager.signInWithEmail(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password
                )
            }) {
                if authManager.isLoading {
                    ProgressView()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                } else {
                    Text("Anmelden")
                        .fontWeight(.semibold)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(authManager.isLoading)

            HStack {
                Text("Noch kein Konto?")
                Button("Registrieren") {
                    navigateToSignUp()
                }
            }
            .padding(.top, 15)

            Spacer()
        }
        .padding()
        // .navigationTitle("Anmelden") // Normalerweise nicht nötig, wenn in einem Modal/Sheet
        .onReceive(authManager.$user) { firebaseUser in
            if firebaseUser != nil {
                onLoginSuccess() // Schließe das Modal/Sheet bei erfolgreichem Login
            }
        }
        // Optional: Lausche auf errorID, um validationError zurückzusetzen,
        // falls ein neuer authError auftritt (ähnlich wie in SignUpView).
        .onChange(of: authManager.errorID) {
            if authManager.authError != nil {
                validationError = nil
            }
        }
    }
    
    // Einfache E-Mail-Validierungsfunktion (könnte in eine Utility-Klasse ausgelagert werden)
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Preview Provider (optional, aber hilfreich)
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthManager = FirebaseAuthManager()
        // Beispiel: Simulieren eines Fehlers für die Preview
        // mockAuthManager.authError = NSError(domain: "PreviewError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ungültige Anmeldedaten (Preview)."])
        
        return LoginView(
            onLoginSuccess: { print("Preview: Login Success!") },
            navigateToSignUp: { print("Preview: Navigate to Sign Up!") }
        )
        .environmentObject(mockAuthManager)
    }
}
