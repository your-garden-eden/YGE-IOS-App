import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager
    @State private var showingAuthSheet = false
    private enum AuthSheetView { case login, signUp }
    @State private var currentAuthSheet: AuthSheetView = .login

    var body: some View {
        NavigationStack {
            Group {
                if let user = authManager.user {
                    loggedInView(user: user)
                } else {
                    loggedOutView()
                }
            }
            .navigationTitle("Mein Profil")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPage, for: .navigationBar)
        }
        .sheet(isPresented: $showingAuthSheet) {
            authManager.authError = nil
        } content: {
            switch currentAuthSheet {
            case .login:
                NavigationStack {
                    LoginView(
                        onLoginSuccess: { showingAuthSheet = false },
                        navigateToSignUp: { currentAuthSheet = .signUp }
                    )
                }
                .environmentObject(authManager)
                
            case .signUp:
                NavigationStack {
                    SignUpView(
                        onSignUpSuccess: { showingAuthSheet = false },
                        navigateToLogin: { currentAuthSheet = .login }
                    )
                }
                .environmentObject(authManager)
            }
        }
    }


    // MARK: - Logged In View
    @ViewBuilder
    private func loggedInView(user: UserModel) -> some View {
        List {
            // BENUTZERINFORMATIONEN SECTION
            Section(header: Text("Benutzerinformationen").foregroundStyle(AppColors.textMuted)) {
                InfoRow(label: "Name", value: user.fullName)
                InfoRow(label: "E-Mail", value: user.email ?? "Keine E-Mail")
                if let wcId = user.wooCommerceCustomerId {
                    InfoRow(label: "Kunden-ID", value: "\(wcId)")
                }
            }
            .listRowBackground(AppColors.backgroundComponent)

            // KORREKTUR: Die "Konto"-Section mit dem ungültigen NavigationLink wurde entfernt.
            // Sobald du eine EditProfilView erstellst, kannst du sie hier wieder hinzufügen.
            
            // ABMELDEN SECTION
            Section {
                Button(role: .destructive) {
                    authManager.signOut()
                } label: {
                    Label("Abmelden", systemImage: "arrow.right.square")
                        .foregroundStyle(AppColors.error)
                }
            }
            .listRowBackground(AppColors.backgroundComponent)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppColors.backgroundPage)
    }

    // MARK: - Logged Out View
    @ViewBuilder
    private func loggedOutView() -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .padding(.bottom, 20)
            
            VStack(spacing: 8) {
                Text("Willkommen zurück")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textHeadings)
                
                Text("Melde dich an, um deine Bestellungen und mehr zu verwalten.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    currentAuthSheet = .login
                    showingAuthSheet = true
                }) {
                    Text("Anmelden")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .foregroundStyle(AppColors.textOnPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button(action: {
                    currentAuthSheet = .signUp
                    showingAuthSheet = true
                }) {
                    Text("Neues Konto erstellen")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.backgroundLightGray)
                        .foregroundStyle(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColors.borderLight, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPage)
    }
}

// MARK: - Helper View: InfoRow
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(AppColors.textBase)
            Spacer()
            Text(value)
                .foregroundStyle(AppColors.textMuted)
                .multilineTextAlignment(.trailing)
        }
    }
}
