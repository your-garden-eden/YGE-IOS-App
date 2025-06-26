//
//  AuthContainerView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 25.06.25.
//


// DATEI: AuthViews.swift
// PFAD: Features/Auth/Views/AuthViews.swift
// VERSION: 1.2 (FINAL & UNGEKÜRZT)
// STATUS: Sammlung aller Authentifizierungs-Views.

import SwiftUI

// MARK: - AuthContainerView
struct AuthContainerView: View {
    @EnvironmentObject var authManager: AuthManager
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            LoginView()
        }
        .environmentObject(authManager)
        .onReceive(authManager.$authState) { newState in
            if newState == .authenticated {
                onDismiss()
            }
        }
    }
}

// MARK: - LoginView
struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""

    var body: some View {
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
                    if authManager.isLoading {
                        ProgressView().tint(AppTheme.Colors.textOnPrimary)
                    } else {
                        Text("Anmelden")
                    }
                }
                .buttonStyle(AppTheme.PrimaryButtonStyle())
                .disabled(authManager.isLoading || username.isEmpty || password.isEmpty)

                signUpPrompt
                
            }.padding()
        }
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Anmelden")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authManager.authError = nil
        }
    }
    
    private var inputFields: some View {
        VStack(spacing: 0) {
            TextField("Benutzername oder E-Mail", text: $username)
                .padding()
                .textContentType(.username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Divider().background(AppTheme.Colors.borderLight)
            
            VStack(alignment: .trailing, spacing: AppTheme.Layout.Spacing.small) {
                SecureField("Passwort", text: $password)
                    .padding([.leading, .trailing, .top])
                    .textContentType(.password)
                
                HStack {
                    Spacer()
                    NavigationLink("Passwort vergessen?") { ForgotPasswordView() }
                    Text("|").foregroundColor(AppTheme.Colors.borderLight)
                    NavigationLink("Benutzername?") { RequestUsernameView() }
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
        let trimmedUsername = self.username.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            do {
                _ = try await authManager.login(usernameOrEmail: trimmedUsername, password: password)
            } catch {
                // Fehler wird im authManager.authError-Publisher behandelt und in der UI angezeigt.
            }
        }
    }
}

// MARK: - SignUpView
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
            }.padding()
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
            
            inputFields
            
            if let error = authManager.authError {
                Text(error)
                    .foregroundColor(AppTheme.Colors.error)
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: performSignUp) {
                if authManager.isLoading {
                    ProgressView().tint(AppTheme.Colors.textOnPrimary)
                } else {
                    Text("Konto erstellen")
                }
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
            
            Text("Ihr Konto wurde erstellt. Sie können sich nun anmelden.")
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
                TextField("Vorname", text: $firstName).textContentType(.givenName)
                TextField("Nachname", text: $lastName).textContentType(.familyName)
                TextField("Straße & Hausnummer", text: $address1).textContentType(.streetAddressLine1)
                TextField("Postleitzahl", text: $postcode).textContentType(.postalCode).keyboardType(.numberPad)
                TextField("Stadt", text: $city).textContentType(.addressCity)
                TextField("Telefonnummer", text: $phone).textContentType(.telephoneNumber).keyboardType(.phonePad)
            }
            Group {
                TextField("Benutzername (ohne '@')", text: $username).textContentType(.username).autocapitalization(.none)
                TextField("E-Mail", text: $email).keyboardType(.emailAddress).autocapitalization(.none).textContentType(.emailAddress)
                SecureField("Passwort (min. 6 Zeichen)", text: $password).textContentType(.newPassword)
                SecureField("Passwort bestätigen", text: $confirmPassword).textContentType(.newPassword)
            }
        }
        .textFieldStyle(AppTheme.PlainTextFieldStyle())
        .padding(.horizontal)
    }

    private var loginPrompt: some View {
        HStack {
            Text("Bereits ein Konto?")
            Button("Anmelden") { dismiss() }
                .tint(AppTheme.Colors.primary)
        }
        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
        .padding(.top)
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
}

// MARK: - ForgotPasswordView
struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var successMessage: String?
    
    var body: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Text("Passwort zurücksetzen")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
            
            Text("Geben Sie Ihre E-Mail-Adresse ein. Wir senden Ihnen einen Link zum Zurücksetzen.")
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.Colors.textMuted)

            TextField("E-Mail", text: $email)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .background(AppTheme.Colors.backgroundComponent)
                .cornerRadius(AppTheme.Layout.BorderRadius.large)
                .appShadow(AppTheme.Shadows.small)
            
            if let error = authManager.authError { Text(error).foregroundColor(AppTheme.Colors.error) }
            if let success = successMessage { Text(success).foregroundColor(AppTheme.Colors.success) }
            
            Button(action: performPasswordResetRequest) {
                if authManager.isLoading {
                    ProgressView().tint(AppTheme.Colors.textOnPrimary)
                } else {
                    Text("Link anfordern")
                }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(authManager.isLoading || email.isEmpty)
            
            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Passwort vergessen")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .onAppear {
            authManager.authError = nil
            successMessage = nil
        }
    }
    
    private func performPasswordResetRequest() {
        Task {
            do {
                let response = try await authManager.requestPasswordReset(email: email)
                self.successMessage = response.message
                authManager.authError = nil
            } catch {}
        }
    }
}

// MARK: - RequestUsernameView
struct RequestUsernameView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var successMessage: String?
    
    var body: some View {
        VStack(spacing: AppTheme.Layout.Spacing.large) {
            Text("Benutzername vergessen?")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h2, weight: .bold))
            
            Text("Geben Sie Ihre E-Mail-Adresse ein, um Ihren Benutzernamen anzufordern.")
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.Colors.textMuted)

            TextField("E-Mail", text: $email)
                .padding()
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .background(AppTheme.Colors.backgroundComponent)
                .cornerRadius(AppTheme.Layout.BorderRadius.large)
                .appShadow(AppTheme.Shadows.small)
            
            if let error = authManager.authError { Text(error).foregroundColor(AppTheme.Colors.error) }
            if let success = successMessage { Text(success).foregroundColor(AppTheme.Colors.success) }
            
            Button(action: performUsernameRequest) {
                if authManager.isLoading {
                    ProgressView().tint(AppTheme.Colors.textOnPrimary)
                } else {
                    Text("Benutzername anfordern")
                }
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .disabled(authManager.isLoading || email.isEmpty)
            
            Spacer()
        }
        .padding()
        .background(AppTheme.Colors.backgroundPage.ignoresSafeArea())
        .navigationTitle("Benutzername anfordern")
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