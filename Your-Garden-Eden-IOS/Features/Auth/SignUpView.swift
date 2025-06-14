// Path: Your-Garden-Eden-IOS/Features/Auth/SignUpView.swift

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var apiError: String?

    var onDismiss: () -> Void
    var navigateToLogin: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppStyles.Spacing.large) {
                    Text("Konto erstellen")
                        .font(AppFonts.montserrat(size: AppFonts.Size.h2, weight: .bold))
                        .foregroundColor(AppColors.textHeadings)

                    inputFields

                    if let error = apiError {
                        Text(error)
                            .foregroundColor(AppColors.error).font(AppFonts.roboto(size: AppFonts.Size.caption)).multilineTextAlignment(.center).padding(.horizontal)
                    }

                    Button(action: performSignUp) {
                        if authManager.isLoading { ProgressView().tint(AppColors.textOnPrimary) }
                        else { Text("Registrieren") }
                    }
                    .buttonStyle(PrimaryButtonStyle()).disabled(authManager.isLoading)

                    loginPrompt
                }
                .padding()
            }
            .background(AppColors.backgroundPage.ignoresSafeArea())
            .navigationTitle("Registrieren")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Abbrechen", action: onDismiss) } }
            .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in if isLoggedIn { onDismiss() } }
        }
    }

    private var inputFields: some View {
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
        .background(AppColors.backgroundComponent).cornerRadius(AppStyles.BorderRadius.large).appShadow(AppStyles.Shadows.small)
    }

    private var loginPrompt: some View {
        HStack {
            Text("Bereits ein Konto?").foregroundColor(AppColors.textMuted)
            Button("Anmelden", action: navigateToLogin).tint(AppColors.primary)
        }
        .font(AppFonts.roboto(size: AppFonts.Size.body)).padding(.top)
    }

    private func performSignUp() {
        apiError = nil
        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstName = self.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = self.lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            apiError = "Bitte alle Felder ausfüllen."
            return
        }
        guard password.count >= 6 else {
            apiError = "Das Passwort muss mindestens 6 Zeichen lang sein."
            return
        }
        guard password == confirmPassword else {
            apiError = "Die Passwörter stimmen nicht überein."
            return
        }
        
        Task {
            do {
                try await authManager.signUpWithEmail(
                    email: email, password: password,
                    firstName: firstName, lastName: lastName
                )
            } catch {
                self.apiError = error.localizedDescription
            }
        }
    }
}
