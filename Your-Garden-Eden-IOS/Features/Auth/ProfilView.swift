// Path: Your-Garden-Eden-IOS/Features/Auth/ProfilView.swift

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var showingAuthSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPage.ignoresSafeArea()
                
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
                Text("Meine Bestellungen (in Kürze)")
                    .foregroundColor(AppColors.textMuted)
            }
            
            Section {
                Button("Abmelden", role: .destructive) {
                    authManager.logout()
                }
                .foregroundColor(AppColors.error)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

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
                self.showingAuthSheet = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top)
        }
        .padding()
    }
}
