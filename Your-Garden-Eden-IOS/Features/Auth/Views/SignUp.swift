import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = "" // Zusätzliches Feld
    @State private var lastName = ""  // Zusätzliches Feld

    var onSignUpSuccess: () -> Void // Callback
    var navigateToLogin: () -> Void // Callback

    var body: some View {
        VStack(spacing: 20) {
            Text("Konto erstellen")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Vorname", text: $firstName)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            TextField("Nachname", text: $lastName)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            TextField("E-Mail", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            SecureField("Passwort", text: $password)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            
            SecureField("Passwort bestätigen", text: $confirmPassword)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

            if authManager.isLoading {
                ProgressView()
            } else {
                Button("Registrieren") {
                    if password == confirmPassword {
                        let additionalData = [
                            "firstName": firstName,
                            "lastName": lastName
                        ]
                        authManager.signUpWithEmail(email: email, password: password, additionalData: additionalData)
                    } else {
                        authManager.errorMessage = "Die Passwörter stimmen nicht überein."
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || firstName.isEmpty || lastName.isEmpty)
            }
            
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("Bereits ein Konto? Anmelden") {
                navigateToLogin()
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
        // .navigationTitle("Registrieren")
        .onReceive(authManager.$user) { user in
             if user != nil {
                 onSignUpSuccess()
             }
        }
    }
}

// Preview (optional)
// struct SignUpView_Previews: PreviewProvider {
//     static var previews: some View {
//         SignUpView(onSignUpSuccess: {}, navigateToLogin: {})
//             .environmentObject(FirebaseAuthManager())
//     }
// }
