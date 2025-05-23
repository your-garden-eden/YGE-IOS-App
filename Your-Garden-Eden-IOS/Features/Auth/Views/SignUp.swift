// Your-Garden-Eden-IOS/Features/Auth/Views/SignUpView.swift

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""

    @State private var validationError: String? // Für lokale UI-Validierungsfehler

    var onSignUpSuccess: () -> Void
    var navigateToLogin: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Text("Konto erstellen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            TextField("Vorname", text: $firstName)
                .textContentType(.givenName)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .autocapitalization(.words)

            TextField("Nachname", text: $lastName)
                .textContentType(.familyName)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .autocapitalization(.words)

            TextField("E-Mail", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            SecureField("Passwort (min. 6 Zeichen)", text: $password)
                .textContentType(.newPassword)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            
            SecureField("Passwort bestätigen", text: $confirmPassword)
                .textContentType(.newPassword)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            // Fehleranzeige-Logik
            if let validationError = validationError {
                Text(validationError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
            } else if let authError = authManager.authError {
                Text(authError.localizedDescription)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
            }

            Button(action: {
                // Fehler zurücksetzen vor neuem Versuch
                validationError = nil
                // authManager.authError = nil // Wird jetzt im AuthManager selbst gemacht beim Start der Aktionen

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
            }) {
                if authManager.isLoading {
                    ProgressView()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                } else {
                    Text("Registrieren")
                        .fontWeight(.semibold)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(authManager.isLoading)

            HStack {
                Text("Bereits ein Konto?")
                Button("Anmelden") {
                    navigateToLogin()
                }
            }
            .padding(.top, 15)
            
            Spacer()
        }
        .padding()
        .onReceive(authManager.$user) { firebaseUser in // Beobachtet direkt das User-Objekt
             if firebaseUser != nil {
                 onSignUpSuccess()
             }
        }
        // Lausche auf die Änderung der errorID
        .onChange(of: authManager.errorID) { // Hier nur den neuen Wert der errorID ignorieren
            // Wenn sich errorID ändert, bedeutet das, dass authError sich geändert hat (oder wurde).
            // Wenn ein neuer authError vom AuthManager kommt, lösche den lokalen validationError.
            if authManager.authError != nil { // Prüfe, ob tatsächlich ein Fehler im authManager vorliegt
                validationError = nil
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Preview Provider
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthManager = FirebaseAuthManager()
        // Beispiel: Simulieren eines Fehlers für die Preview
        // mockAuthManager.authError = NSError(domain: "PreviewError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Dies ist ein Testfehler."])
        
        return SignUpView(
            onSignUpSuccess: { print("Preview: SignUp Success!") },
            navigateToLogin: { print("Preview: Navigate to Login!") }
        )
        .environmentObject(mockAuthManager)
    }
}
