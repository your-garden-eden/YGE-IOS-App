// Dateiname: Features/Auth/LoginView.swift

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var validationError: String?

    var onDismiss: () -> Void
    var navigateToSignUp: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Willkommen zurück!")
                .font(AppFonts.montserrat(size: AppFonts.Size.h2, weight: .bold))
                .foregroundColor(AppColors.textHeadings)

            VStack(spacing: 0) {
                TextField("E-Mail", text: $email)
                    .padding()
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                
                Divider().background(AppColors.borderLight)
                
                SecureField("Passwort", text: $password)
                    .padding()
                    .textContentType(.password)
            }
            .background(AppColors.backgroundComponent)
            .cornerRadius(AppStyles.BorderRadius.large)
            .appShadow(AppStyles.Shadows.small)

            if let error = validationError ?? authManager.authError?.localizedDescription {
                Text(error)
                    .foregroundColor(AppColors.error)
                    .font(AppFonts.roboto(size: AppFonts.Size.caption))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: performSignIn) {
                if authManager.isLoading {
                    ProgressView().tint(AppColors.textOnPrimary)
                } else {
                    Text("Anmelden")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(authManager.isLoading)

            HStack {
                Text("Noch kein Konto?")
                    .foregroundColor(AppColors.textMuted)
                Button("Registrieren") {
                    navigateToSignUp()
                }
                .tint(AppColors.primary)
            }
            .font(AppFonts.roboto(size: AppFonts.Size.body))
            .padding(.top)

            Spacer()
        }
        .padding()
        .background(AppColors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Anmelden")
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
            // Die neue Syntax ohne Parameter, wenn man sie nicht braucht.
            if authManager.authError != nil {
                validationError = nil
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

// HILFS-STIL FÜR BUTTONS (Kann in eine eigene Datei, z.B. AppStyles.swift)
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .bold))
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? AppColors.primaryDark : AppColors.primary)
            .foregroundColor(AppColors.textOnPrimary)
            .cornerRadius(AppStyles.BorderRadius.large)
            .appShadow(AppStyles.Shadows.small)
    }
}
