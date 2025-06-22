// DATEI: SignUpView.swift
// PFAD: Features/Auth/Views/SignUpView.swift
// VERSION: ADLERAUGE 1.0 (REVIDIERT)
// STATUS: ZURÜCKGESETZT

import SwiftUI
// import GoogleSignIn <- ENTFERNT

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var address1 = ""
    @State private var postcode = ""
    @State private var city = ""
    @State private var phone = ""
    @State private var country = "DE"
    
    @State private var registrationSuccess = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Layout.Spacing.large) {
                if registrationSuccess {
                    successView
                } else {
                    registrationForm
                }
            }
            .padding()
        }
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle(registrationSuccess ? "Erfolg" : "Konto erstellen")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .onAppear {
            authManager.authError = nil
        }
    }
    
    private var registrationForm: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Text("Konto erstellen")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
                .foregroundColor(AppTheme.Colors.textHeadings)

            // --- BEGINN RÜCKBAU ---
            // Der "Mit Google registrieren"-Button und der "ODER"-Trenner wurden entfernt.
            // --- ENDE RÜCKBAU ---

            inputFields

            if let error = authManager.authError {
                Text(error)
                    .foregroundColor(AppTheme.Colors.error)
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button(action: performSignUp) {
                if authManager.isLoading { ProgressView().tint(AppTheme.Colors.textOnPrimary) }
                else { Text("Konto erstellen") }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(authManager.isLoading)

            loginPrompt
        }
    }
    
    private var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.success)
            
            Text("Registrierung erfolgreich!")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold))
            
            Text("Ihr Konto wurde erstellt. Bitte prüfen Sie Ihr E-Mail-Postfach für eine Willkommensnachricht. Sie können sich nun anmelden.")
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.Colors.textMuted)

            Button("Zurück zum Login") {
                dismiss()
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .padding(.top)
        }
    }

    private var inputFields: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            Group {
                TextField("Vorname", text: $firstName).textContentType(.givenName).autocapitalization(.words)
                TextField("Nachname", text: $lastName).textContentType(.familyName).autocapitalization(.words)
                TextField("Straße & Hausnummer", text: $address1).textContentType(.streetAddressLine1)
                TextField("Postleitzahl", text: $postcode).textContentType(.postalCode).keyboardType(.numberPad)
                TextField("Stadt", text: $city).textContentType(.addressCity)
                TextField("Telefonnummer", text: $phone).textContentType(.telephoneNumber).keyboardType(.phonePad)
            }
            
            Group {
                TextField("Benutzername (ohne '@')", text: $username)
                    .textContentType(.username).autocapitalization(.none).disableAutocorrection(true)
                TextField("E-Mail", text: $email)
                    .keyboardType(.emailAddress).autocapitalization(.none).disableAutocorrection(true).textContentType(.emailAddress)
                SecureField("Passwort (min. 6 Zeichen)", text: $password)
                    .textContentType(.newPassword)
                SecureField("Passwort bestätigen", text: $confirmPassword)
                    .textContentType(.newPassword)
            }
        }
        .textFieldStyle(AppTheme.PlainTextFieldStyle())
        // Das horizontale Padding wird hier beibehalten, da es für das Layout des Formulars selbst sinnvoll ist.
        .padding(.horizontal)
    }

    private var loginPrompt: some View {
        HStack {
            Text("Bereits ein Konto?")
            Button("Anmelden") { dismiss() }
                .tint(AppTheme.Colors.primary)
        }
        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)).padding(.top)
    }

    private func performSignUp() {
        authManager.authError = nil
        let fields = [username, email, password, firstName, lastName, address1, postcode, city, phone]
        guard fields.allSatisfy({ !$0.trimmingCharacters(in: .whitespaces).isEmpty }) else {
            authManager.authError = "Bitte alle Felder ausfüllen."; return
        }
        guard !username.contains("@") else {
            authManager.authError = "Der Benutzername darf kein '@'-Zeichen enthalten."; return
        }
        guard password.count >= 6 else {
            authManager.authError = "Das Passwort muss mindestens 6 Zeichen lang sein."; return
        }
        guard password == confirmPassword else {
            authManager.authError = "Die Passwörter stimmen nicht überein."; return
        }
        
        let payload = RegistrationPayload(
            username: username.trimmingCharacters(in: .whitespaces), email: email.trimmingCharacters(in: .whitespaces),
            password: password, first_name: firstName.trimmingCharacters(in: .whitespaces),
            last_name: lastName.trimmingCharacters(in: .whitespaces), address_1: address1.trimmingCharacters(in: .whitespaces),
            postcode: postcode.trimmingCharacters(in: .whitespaces), city: city.trimmingCharacters(in: .whitespaces),
            billing_country: country, billing_phone: phone.trimmingCharacters(in: .whitespaces)
        )
        
        Task {
            do {
                _ = try await authManager.register(payload: payload)
                self.registrationSuccess = true
            } catch {}
        }
    }
    
    // --- BEGINN RÜCKBAU ---
    // Die Funktion performGoogleSignIn wurde vollständig entfernt.
    // --- ENDE RÜCKBAU ---
}
