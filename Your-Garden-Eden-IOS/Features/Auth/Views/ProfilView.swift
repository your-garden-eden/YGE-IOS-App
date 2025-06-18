//
//  ProfilView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: ProfilView.swift
// PFAD: Features/Profile/Views/ProfilView.swift
// ZWECK: Stellt die Profil-Ansicht für den eingeloggten Benutzer dar oder zeigt
//        eine Aufforderung zum Anmelden/Registrieren für Gäste an.

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var showingAuthSheet = false

    var body: some View {
        // Diese View ist die Wurzel der Navigation innerhalb ihres Tabs.
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
            // Präsentiert den zentralen Authentifizierungs-Flow als modales Sheet.
            AuthContainerView(onDismiss: { self.showingAuthSheet = false })
                .environmentObject(authManager)
        }
    }

    private func loggedInView(user: UserModel) -> some View {
        List {
            Section(header: Text("Benutzerinformationen")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text("\(user.firstName) \(user.lastName)")
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
                HStack {
                    Text("E-Mail")
                    Spacer()
                    Text(user.email)
                        .foregroundColor(AppTheme.Colors.textMuted)
                }
            }
            
            Section {
                Text("Meine Bestellungen (in Kürze)")
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
            
            Section {
                Button("Abmelden", role: .destructive) {
                    authManager.logout()
                }
                .foregroundColor(AppTheme.Colors.error)
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
}