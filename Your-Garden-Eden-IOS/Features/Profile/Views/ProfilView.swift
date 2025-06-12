// Features/Profile/ProfilView.swift

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var showingAuthSheet = false
    @State private var currentAuthSheet: AuthSheetType = .login
    
    enum AuthSheetType {
        case login
        case signUp
    }

    var body: some View {
        NavigationStack {
            Group {
                if let user = authManager.user {
                    loggedInView(user: user)
                } else {
                    loggedOutView
                }
            }
            .navigationTitle("Mein Profil")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAuthSheet) {
            authSheetView
        }
    }

    private func loggedInView(user: User) -> some View {
        List {
            Section(header: Text("Benutzerinformationen")) {
                HStack { Text("Name"); Spacer(); Text("\(user.firstName) \(user.lastName)").foregroundColor(.secondary) }
                HStack { Text("E-Mail"); Spacer(); Text(user.email).foregroundColor(.secondary) }
            }
            Section { Text("Meine Bestellungen") }
            Section { Button("Abmelden", role: .destructive) { authManager.logout() } }
        }
        .listStyle(.grouped)
    }

    private var loggedOutView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark").font(.system(size: 80)).foregroundColor(.gray.opacity(0.5))
            Text("Du bist nicht angemeldet").font(.title2).fontWeight(.bold)
            Text("Melde dich an, um deine Bestellungen zu sehen, deine Wunschliste zu speichern und mehr.").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal, 40)
            Button("Anmelden oder Registrieren") {
                self.currentAuthSheet = .login
                self.showingAuthSheet = true
            }
            .font(.headline).padding(.horizontal, 30).padding(.vertical, 12).background(Color.accentColor).foregroundColor(.white).cornerRadius(12)
        }
        .padding()
    }
    
    // --- KORREKTUR: @ViewBuilder hinzugefügt, um den Typen-Konflikt zu lösen ---
    @ViewBuilder
    private var authSheetView: some View {
        switch currentAuthSheet {
        case .login:
            LoginView(
                onLoginSuccess: { self.showingAuthSheet = false },
                navigateToSignUp: { self.currentAuthSheet = .signUp }
            )
        case .signUp:
            SignUpView(
                onSignUpSuccess: { self.showingAuthSheet = false },
                navigateToLogin: { self.currentAuthSheet = .login }
            )
        }
    }
}
