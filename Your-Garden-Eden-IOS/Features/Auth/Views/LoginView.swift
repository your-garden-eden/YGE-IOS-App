// Features/Auth/LoginView.swift

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var validationError: String?

    // Callbacks, um das Sheet zu steuern
    var onLoginSuccess: () -> Void
    var navigateToSignUp: () -> Void

    var body: some View {
        // Der NavigationStack ist korrekt für eine modale Ansicht,
        // die ihre eigene Hierarchie und Toolbar hat.
        NavigationStack {
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
                    .textContentType(.password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                // Fehleranzeige
                if let validationError = validationError {
                    Text(validationError)
                        .foregroundColor(.red).font(.caption).multilineTextAlignment(.center)
                } else if let authError = authManager.authError {
                    Text(authError.localizedDescription)
                        .foregroundColor(.red).font(.caption).multilineTextAlignment(.center)
                }

                Button(action: performSignIn) {
                    if authManager.isLoading {
                        ProgressView()
                            .frame(height: 50).frame(maxWidth: .infinity)
                            .background(Color.accentColor.opacity(0.8))
                            .foregroundColor(.white).cornerRadius(8)
                    } else {
                        Text("Anmelden")
                            .fontWeight(.semibold).frame(height: 50).frame(maxWidth: .infinity)
                            .background(Color.accentColor).foregroundColor(.white).cornerRadius(8)
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
            .navigationTitle("Anmelden")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Abbrechen") { onLoginSuccess() }
                 }
            }
            // KORREKTUR: Modernisierte onChange-Syntax
            .onChange(of: authManager.isLoggedIn) {
                 if authManager.isLoggedIn {
                     onLoginSuccess()
                 }
            }
            // KORREKTUR: Modernisierte onChange-Syntax
            .onChange(of: authManager.errorID) {
                if authManager.authError != nil {
                    validationError = nil
                }
            }
        }
    }
    
    private func performSignIn() {
        validationError = nil
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
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}
