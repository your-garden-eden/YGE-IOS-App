// DATEI: LoginView.swift
// PFAD: Features/Auth/Views/LoginView.swift
// VERSION: FEINSCHLIFF 1.1 (KOMPATIBILITÄTS-KORREKTUR)
// STATUS: REVIDIERT

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        // Die ScrollView bleibt erhalten, sie ist die korrekte Lösung für das
        // ursprüngliche Problem der Auto-Layout-Warnungen.
        ScrollView {
            VStack(spacing: AppTheme.Layout.Spacing.large) {
                Text("Willkommen zurück!")
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textHeadings)
                    .padding(.top, AppTheme.Layout.Spacing.large)

                inputFields

                if let error = authManager.authError {
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
                .disabled(authManager.isLoading || username.isEmpty || password.isEmpty)

                signUpPrompt
            }
            .padding()
        }
        // --- BEGINN KORREKTUR ---
        // Der inkompatible Modifikator .keyboardDismissMode wurde entfernt,
        // um die Kompilierung auf älteren iOS-Versionen sicherzustellen.
        // --- ENDE KORREKTUR ---
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Anmelden")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authManager.authError = nil
        }
    }
    
    private var inputFields: some View {
        VStack(spacing: 0) {
            TextField("Benutzername", text: $username)
                .padding()
                .keyboardType(.default)
                .autocapitalization(.none)
                .textContentType(.username)
            
            Divider().background(AppTheme.Colors.borderLight)
            
            VStack(alignment: .trailing, spacing: AppTheme.Layout.Spacing.small) {
                SecureField("Passwort", text: $password)
                    .padding([.leading, .trailing, .top])
                    .textContentType(.password)
                
                HStack {
                    Spacer()
                    NavigationLink("Passwort vergessen?") { ForgotPasswordView() }
                    Text("|").foregroundColor(AppTheme.Colors.borderLight)
                    NavigationLink("Benutzername vergessen?") { RequestUsernameView() }
                }
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption))
                .padding(.horizontal)
                .padding(.bottom, AppTheme.Layout.Spacing.small)
            }
        }
        .background(AppTheme.Colors.backgroundComponent)
        .cornerRadius(AppTheme.Layout.BorderRadius.large)
        .appShadow(AppTheme.Shadows.small)
    }
    
    private var signUpPrompt: some View {
        HStack {
            Text("Noch kein Konto?")
            NavigationLink("Registrieren") { SignUpView() }
                .tint(AppTheme.Colors.primary)
        }
        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
        .padding(.top)
    }
    
    private func performSignIn() {
        let username = self.username.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            do {
                _ = try await authManager.login(usernameOrEmail: username, password: password)
            } catch {}
        }
    }
}
