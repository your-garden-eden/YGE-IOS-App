//
//  LoginView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: LoginView.swift
// PFAD: Features/Auth/Views/LoginView.swift
// ZWECK: Stellt die Benutzeroberfläche zur Eingabe von Anmeldedaten bereit.
//        Diese View ist eine reine Komponente ohne eigene Navigationslogik.

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var apiError: String?

    var body: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Text("Willkommen zurück!")
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

            Button(action: performSignIn) {
                if authManager.isLoading { ProgressView().tint(AppTheme.Colors.textOnPrimary) }
                else { Text("Anmelden") }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(authManager.isLoading)

            signUpPrompt

            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Anmelden")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var inputFields: some View {
        VStack(spacing: 0) {
            TextField("E-Mail", text: $email)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
            
            Divider().background(AppTheme.Colors.borderLight)
            
            SecureField("Passwort", text: $password)
                .padding()
                .textContentType(.password)
        }
        .background(AppTheme.Colors.backgroundComponent)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.small)
    }
    
    private var signUpPrompt: some View {
        HStack {
            Text("Noch kein Konto?")
                .foregroundColor(AppTheme.Colors.textMuted)
            
            // Nutzt NavigationLink, um zur Registrierungs-View zu wechseln.
            NavigationLink("Registrieren") {
                SignUpView()
            }
            .tint(AppTheme.Colors.primary)
        }
        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
        .padding(.top)
    }
    
    private func performSignIn() {
        apiError = nil
        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty, !password.isEmpty else {
            apiError = "Bitte E-Mail und Passwort eingeben."
            return
        }
        
        Task {
            do {
                try await authManager.signInWithEmail(email: email, password: password)
                // Der onDismiss-Aufruf wird vom Container gehandhabt.
            } catch {
                self.apiError = error.localizedDescription
            }
        }
    }
}