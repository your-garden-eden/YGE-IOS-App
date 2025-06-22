//
//  RequestUsernameView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.06.25.
//


// DATEI: RequestUsernameView.swift
// PFAD: Features/Auth/Views/RequestUsernameView.swift
// VERSION: IDENTITÄT 3.0
// STATUS: NEU

import SwiftUI

struct RequestUsernameView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var successMessage: String?

    var body: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Text("Benutzername vergessen")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
                .foregroundColor(AppTheme.Colors.textHeadings)
            
            Text("Geben Sie Ihre E-Mail-Adresse ein. Wir senden Ihnen Ihren Benutzernamen zu, falls ein Konto existiert.")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)

            TextField("E-Mail", text: $email)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .background(AppTheme.Colors.backgroundComponent)
                .cornerRadius(AppTheme.Layout.BorderRadius.large)
                .appShadow(AppTheme.Shadows.small)
            
            if let error = authManager.authError {
                Text(error)
                    .foregroundColor(AppTheme.Colors.error)
            }
            
            if let success = successMessage {
                Text(success)
                    .foregroundColor(AppTheme.Colors.success)
            }

            Button(action: performUsernameRequest) {
                if authManager.isLoading { ProgressView().tint(AppTheme.Colors.textOnPrimary) }
                else { Text("Benutzernamen anfordern") }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(authManager.isLoading || email.isEmpty)

            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Benutzername vergessen")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .onAppear {
            authManager.authError = nil
            successMessage = nil
        }
    }
    
    private func performUsernameRequest() {
        Task {
            do {
                let response = try await authManager.requestUsername(email: email)
                self.successMessage = response.message
                authManager.authError = nil
            } catch {}
        }
    }
}