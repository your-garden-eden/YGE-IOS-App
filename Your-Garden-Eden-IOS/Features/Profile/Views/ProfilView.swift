// Dateiname: Features/Profile/ProfilView.swift

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var showingAuthSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrundfarbe aus dem Design-System für einen konsistenten Look
                AppColors.backgroundPage.ignoresSafeArea()
                
                // Wähle die passende Ansicht basierend auf dem Login-Status
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
        }
        .sheet(isPresented: $showingAuthSheet) {
            // KORREKTUR: Wir präsentieren jetzt die AuthContainerView.
            // Sie kümmert sich selbst um das Umschalten zwischen Login und Registrierung.
            AuthContainerView(onDismiss: {
                self.showingAuthSheet = false
            })
            // Wichtig: Wir müssen den AuthManager an das Sheet weitergeben.
            .environmentObject(authManager)
        }
    }

    // Die Ansicht für eingeloggte Benutzer.
    private func loggedInView(user: User) -> some View {
        List {
            Section(header: Text("Benutzerinformationen")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text("\(user.firstName) \(user.lastName)")
                        .foregroundColor(AppColors.textMuted)
                }
                HStack {
                    Text("E-Mail")
                    Spacer()
                    Text(user.email)
                        .foregroundColor(AppColors.textMuted)
                }
            }
            
            Section {
                // TODO: Hier könnte die Navigation zur Bestellhistorie hin.
                Text("Meine Bestellungen")
            }
            
            Section {
                Button("Abmelden", role: .destructive) {
                    authManager.logout()
                }
                .foregroundColor(AppColors.error)
            }
        }
        .listStyle(.insetGrouped) // Passt besser zum Design-System
        .scrollContentBackground(.hidden) // Lässt den Hintergrund durchscheinen
    }

    // Die Ansicht für Gäste (nicht eingeloggte Benutzer).
    private var loggedOutView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundColor(AppColors.primary.opacity(0.6))
            
            Text("Du bist nicht angemeldet")
                .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold))
                .foregroundColor(AppColors.textHeadings)
            
            Text("Melde dich an, um deine Bestellungen zu sehen, deine Wunschliste zu speichern und mehr.")
                .font(AppFonts.roboto(size: AppFonts.Size.body))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Anmelden oder Registrieren") {
                // Öffnet das Auth-Sheet
                self.showingAuthSheet = true
            }
            .buttonStyle(PrimaryButtonStyle()) // Verwendet den konsistenten Button-Stil
            .padding(.top)
        }
        .padding()
    }
}


// MARK: - SwiftUI Preview

#Preview {
    // Stellt eine Vorschau für eingeloggte und ausgeloggte Zustände bereit.
    // So können Sie beide Fälle im Canvas sehen.
    ProfilView()
        .environmentObject(AuthManager.shared) // Hier könnte man einen Mock-AuthManager verwenden.
}
