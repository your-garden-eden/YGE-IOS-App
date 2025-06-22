// DATEI: ProfilView.swift
// PFAD: Features/Profile/Views/ProfilView.swift
// VERSION: IDENTITÄT 3.0
// STATUS: MODIFIZIERT

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authManager: AuthManager
    
    // NEU: Zustandsvariablen für die Passwortänderung
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var changePasswordSuccessMessage: String?
    @State private var changePasswordErrorMessage: String?

    @State private var showingAuthSheet = false

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            
            Group {
                if let user = authManager.user {
                    loggedInView(user: user)
                } else {
                    loggedOutView
                }
            }
        }
        .navigationTitle("Mein Profil")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAuthSheet) {
            AuthContainerView(onDismiss: { self.showingAuthSheet = false })
                .environmentObject(authManager)
        }
    }

    private func loggedInView(user: UserModel) -> some View {
        List {
            Section(header: Text("Benutzerinformationen")) {
                HStack { Text("Benutzername"); Spacer(); Text(user.username).foregroundColor(.secondary) }
                HStack { Text("Name"); Spacer(); Text("\(user.firstName) \(user.lastName)").foregroundColor(.secondary) }
                HStack { Text("E-Mail"); Spacer(); Text(user.email).foregroundColor(.secondary) }
            }
            
            // NEU: Sektion zur Passwortänderung
            Section(header: Text("Passwort ändern")) {
                SecureField("Aktuelles Passwort", text: $currentPassword)
                SecureField("Neues Passwort", text: $newPassword)
                SecureField("Neues Passwort bestätigen", text: $confirmNewPassword)
                
                if let msg = changePasswordErrorMessage { Text(msg).foregroundColor(.red).font(.caption) }
                if let msg = changePasswordSuccessMessage { Text(msg).foregroundColor(.green).font(.caption) }
                
                Button("Passwort speichern") {
                    performPasswordChange()
                }
                .disabled(authManager.isLoading || currentPassword.isEmpty || newPassword.isEmpty)
            }
            
            Section(header: Text("Bestellungen")) {
                Text("Meine Bestellungen (in Kürze)")
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
            
            Section {
                Button("Abmelden", role: .destructive) {
                    authManager.logout()
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var loggedOutView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.6))
            
            Text("Du bist nicht angemeldet")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.title2, weight: .bold))
                .foregroundColor(AppTheme.Colors.textHeadings)
            
            Text("Melde dich an, um deine Bestellungen zu sehen, deine Wunschliste zu speichern und mehr.")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Anmelden oder Registrieren") {
                self.showingAuthSheet = true
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .padding(.top)
        }
        .padding()
    }
    
    // NEU: Funktion zur Ausführung der Passwortänderung.
    private func performPasswordChange() {
        changePasswordErrorMessage = nil
        changePasswordSuccessMessage = nil
        
        guard newPassword == confirmNewPassword else {
            changePasswordErrorMessage = "Die neuen Passwörter stimmen nicht überein."
            return
        }
        guard newPassword.count >= 6 else {
            changePasswordErrorMessage = "Das neue Passwort muss mindestens 6 Zeichen haben."
            return
        }
        
        let payload = ChangePasswordPayload(current_password: currentPassword, new_password: newPassword)
        
        Task {
            do {
                let response = try await authManager.changePassword(payload: payload)
                changePasswordSuccessMessage = response.message
                // Felder nach Erfolg leeren
                currentPassword = ""
                newPassword = ""
                confirmNewPassword = ""
            } catch {
                changePasswordErrorMessage = error.localizedDescription
            }
        }
    }
}
