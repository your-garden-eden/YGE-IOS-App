// Dateiname: Features/Auth/SignUpView.swift

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var validationError: String?

    var onDismiss: () -> Void
    var navigateToLogin: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Konto erstellen")
                    .font(AppFonts.montserrat(size: AppFonts.Size.h2, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)

                VStack(spacing: 0) {
                    TextField("Vorname", text: $firstName).padding().textContentType(.givenName).autocapitalization(.words)
                    Divider().background(AppColors.borderLight)
                    TextField("Nachname", text: $lastName).padding().textContentType(.familyName).autocapitalization(.words)
                    Divider().background(AppColors.borderLight)
                    TextField("E-Mail", text: $email).padding().keyboardType(.emailAddress).autocapitalization(.none).textContentType(.emailAddress)
                    Divider().background(AppColors.borderLight)
                    SecureField("Passwort (min. 6 Zeichen)", text: $password).padding().textContentType(.newPassword)
                    Divider().background(AppColors.borderLight)
                    SecureField("Passwort bestätigen", text: $confirmPassword).padding().textContentType(.newPassword)
                }
                .background(AppColors.backgroundComponent)
                .cornerRadius(AppStyles.BorderRadius.large)
                .appShadow(AppStyles.Shadows.small)

                if let error = validationError ?? authManager.authError?.localizedDescription {
                    Text(error)
                        .foregroundColor(AppColors.error).font(AppFonts.roboto(size: AppFonts.Size.caption)).multilineTextAlignment(.center).padding(.horizontal)
                }

                Button(action: performSignUp) {
                    if authManager.isLoading {
                        ProgressView().tint(AppColors.textOnPrimary)
                    } else {
                        Text("Registrieren")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(authManager.isLoading)

                HStack {
                    Text("Bereits ein Konto?")
                        .foregroundColor(AppColors.textMuted)
                    Button("Anmelden") {
                        navigateToLogin()
                    }
                    .tint(AppColors.primary)
                }
                .font(AppFonts.roboto(size: AppFonts.Size.body))
                .padding(.top)
            }
            .padding()
        }
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Registrieren")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
             ToolbarItem(placement: .navigationBarTrailing) {
                 Button("Abbrechen") { onDismiss() }
             }
        }
        // KORREKTUR: Umstellung auf die moderne iOS 17+ onChange-Syntax.
        .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
             if isLoggedIn {
                 onDismiss()
             }
        }
        .onChange(of: authManager.errorID) {
            if authManager.authError != nil {
                validationError = nil
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
