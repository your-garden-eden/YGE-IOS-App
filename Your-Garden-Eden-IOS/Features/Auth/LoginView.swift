import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var apiError: String?

    var onDismiss: () -> Void
    var navigateToSignUp: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: AppStyles.Spacing.large) {
                Text("Willkommen zurück!")
                    .font(AppFonts.montserrat(size: AppFonts.Size.h2, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)

                inputFields

                if let error = apiError {
                    Text(error)
                        .foregroundColor(AppColors.error)
                        .font(AppFonts.roboto(size: AppFonts.Size.caption))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: performSignIn) {
                    if authManager.isLoading { ProgressView().tint(AppColors.textOnPrimary) }
                    else { Text("Anmelden") }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(authManager.isLoading)

                signUpPrompt

                Spacer()
            }
            .padding()
            .background(AppColors.backgroundPage.ignoresSafeArea())
            .navigationTitle("Anmelden")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Abbrechen", action: onDismiss)
                 }
            }
            .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
                 if isLoggedIn { onDismiss() }
            }
        }
    }
    
    private var inputFields: some View {
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
    }
    
    private var signUpPrompt: some View {
        HStack {
            Text("Noch kein Konto?")
                .foregroundColor(AppColors.textMuted)
            Button("Registrieren", action: navigateToSignUp)
            .tint(AppColors.primary)
        }
        .font(AppFonts.roboto(size: AppFonts.Size.body))
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
            } catch {
                self.apiError = error.localizedDescription
            }
        }
    }
}
