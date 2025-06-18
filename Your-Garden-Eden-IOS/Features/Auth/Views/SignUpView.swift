//
//  SignUpView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: SignUpView.swift
// PFAD: Features/Auth/Views/SignUpView.swift
// ZWECK: Stellt die Benutzeroberfläche zur Eingabe von Registrierungsdaten bereit.
//        Diese View ist eine reine Komponente ohne eigene Navigationslogik.

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var apiError: String?

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Layout.Spacing.large) {
                Text("Konto erstellen")
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textHeadings)

                inputFields

                if let error = apiError {
                    Text(error)
                        .foregroundColor(AppTheme.Colors.error)
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: performSignUp) {
                    if authManager.isLoading { ProgressView().tint(AppTheme.Colors.textOnPrimary) }
                    else { Text("Registrieren") }
                }
                .buttonStyle(AppTheme.PrimaryButtonStyle())
                .disabled(authManager.isLoading)

                loginPrompt
            }
            .padding()
        }
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Registrieren")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton() // Nutzt den zentralen Zurück-Button-Stil.
    }

    private var inputFields: some View {
        VStack(spacing: 0) {
            TextField("Vorname", text: $firstName).padding().textContentType(.givenName).autocapitalization(.words)
            Divider().background(AppTheme.Colors.borderLight)
            TextField("Nachname", text: $lastName).padding().textContentType(.familyName).autocapitalization(.words)
            Divider().background(AppTheme.Colors.borderLight)
            TextField("E-Mail", text: $email).padding().keyboardType(.emailAddress).autocapitalization(.none).textContentType(.emailAddress)
            Divider().background(AppTheme.Colors.borderLight)
            SecureField("Passwort (min. 6 Zeichen)", text: $password).padding().textContentType(.newPassword)
            Divider().background(AppTheme.Colors.borderLight)
            SecureField("Passwort bestätigen", text: $confirmPassword).padding().textContentType(.newPassword)
        }
        .background(AppTheme.Colors.backgroundComponent).cornerRadius(AppTheme.Layout.BorderRadius.large).appShadow(AppTheme.Shadows.small)
    }

    private var loginPrompt: some View {
        HStack {
            Text("Bereits ein Konto?")
                .foregroundColor(AppTheme.Colors.textMuted)
            Button("Anmelden") {
                dismiss() // Geht einfach zur vorherigen Ansicht (LoginView) zurück.
            }
            .tint(AppTheme.Colors.primary)
        }
        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)).padding(.top)
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
                try await authManager.signUpWithEmail(email: email, password: password, firstName: firstName, lastName: lastName)
                // Der onDismiss-Aufruf wird vom Container gehandhabt.
            } catch {
                self.apiError = error.localizedDescription
            }
        }
    }
}