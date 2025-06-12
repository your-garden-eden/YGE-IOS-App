// Features/Auth/SignUpView.swift

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var validationError: String?

    var onSignUpSuccess: () -> Void
    var navigateToLogin: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Text("Konto erstellen")
                    .font(.largeTitle).fontWeight(.bold).padding(.bottom, 10)

                TextField("Vorname", text: $firstName).textContentType(.givenName).padding().background(Color(UIColor.systemGray6)).cornerRadius(8).autocapitalization(.words)
                TextField("Nachname", text: $lastName).textContentType(.familyName).padding().background(Color(UIColor.systemGray6)).cornerRadius(8).autocapitalization(.words)
                TextField("E-Mail", text: $email).keyboardType(.emailAddress).autocapitalization(.none).textContentType(.emailAddress).padding().background(Color(UIColor.systemGray6)).cornerRadius(8)
                SecureField("Passwort (min. 6 Zeichen)", text: $password).textContentType(.newPassword).padding().background(Color(UIColor.systemGray6)).cornerRadius(8)
                SecureField("Passwort bestätigen", text: $confirmPassword).textContentType(.newPassword).padding().background(Color(UIColor.systemGray6)).cornerRadius(8)

                if let validationError = validationError {
                    Text(validationError)
                        .foregroundColor(.red).font(.caption).multilineTextAlignment(.center)
                } else if let authError = authManager.authError {
                    Text(authError.localizedDescription)
                        .foregroundColor(.red).font(.caption).multilineTextAlignment(.center)
                }

                Button(action: performSignUp) {
                    if authManager.isLoading {
                        ProgressView().frame(height: 50).frame(maxWidth: .infinity).background(Color.accentColor.opacity(0.8)).foregroundColor(.white).cornerRadius(8)
                    } else {
                        Text("Registrieren").fontWeight(.semibold).frame(height: 50).frame(maxWidth: .infinity).background(Color.accentColor).foregroundColor(.white).cornerRadius(8)
                    }
                }
                .disabled(authManager.isLoading)

                HStack {
                    Text("Bereits ein Konto?")
                    Button("Anmelden") { navigateToLogin() }
                }
                .padding(.top, 15)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Registrieren")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Abbrechen") { onSignUpSuccess() }
                 }
            }
            // KORREKTUR: Modernisierte onChange-Syntax
            .onChange(of: authManager.isLoggedIn) {
                 if authManager.isLoggedIn {
                     onSignUpSuccess()
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

    private func performSignUp() {
        validationError = nil
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            validationError = "Bitte alle Felder ausfüllen."
            return
        }
        guard isValidEmail(email.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            validationError = "Bitte eine gültige E-Mail-Adresse eingeben."
            return
        }
        guard password.count >= 6 else {
            validationError = "Das Passwort muss mindestens 6 Zeichen lang sein."
            return
        }
        guard password == confirmPassword else {
            validationError = "Die Passwörter stimmen nicht überein."
            return
        }

        authManager.signUpWithEmail(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}
