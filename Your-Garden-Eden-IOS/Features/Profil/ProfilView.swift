// DATEI: ProfilView.swift
// PFAD: Features/Profile/Views/ProfilView.swift
// VERSION: STAMMDATEN 1.3 (BESTELLHISTORIE INTEGRIERT)
// STATUS: MODIFIZIERT

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var changePasswordSuccessMessage: String?
    @State private var changePasswordErrorMessage: String?

    @State private var showingAuthSheet = false

    var body: some View {
        // HINWEIS: Ein NavigationStack wird hier benötigt, um den NavigationLink zur
        // Bestellhistorie funktionsfähig zu machen.
        NavigationStack {
            ZStack {
                AppTheme.Colors.backgroundPage.ignoresSafeArea()
                
                Group {
                    if authManager.isLoggedIn {
                        loggedInView
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
    }

    private var loggedInView: some View {
        Form {
            if viewModel.isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            
            if let msg = viewModel.errorMessage {
                Section { Text(msg).foregroundColor(AppTheme.Colors.error) }
            }
            if let msg = viewModel.successMessage {
                Section { Text(msg).foregroundColor(AppTheme.Colors.success) }
            }
            
            Section(header: Text("Rechnungsadresse & Kontaktdaten")) {
                TextField("Vorname", text: $viewModel.billingAddress.firstName)
                TextField("Nachname", text: $viewModel.billingAddress.lastName)
                TextField("Firma (optional)", text: $viewModel.billingAddress.company)
                TextField("Straße & Hausnummer", text: $viewModel.billingAddress.address1)
                TextField("Adresszusatz (optional)", text: $viewModel.billingAddress.address2)
                TextField("Postleitzahl", text: $viewModel.billingAddress.postcode)
                TextField("Stadt", text: $viewModel.billingAddress.city)
            }
            
            Section(header: Text("Lieferadresse")) {
                Toggle(isOn: $viewModel.copyBillingToShipping.animation()) {
                    Text("Identisch mit Rechnungsadresse")
                }
                
                if !viewModel.copyBillingToShipping {
                    Group {
                        TextField("Vorname", text: $viewModel.shippingAddress.firstName)
                        TextField("Nachname", text: $viewModel.shippingAddress.lastName)
                        TextField("Firma (optional)", text: $viewModel.shippingAddress.company)
                        TextField("Straße & Hausnummer", text: $viewModel.shippingAddress.address1)
                        TextField("Adresszusatz (optional)", text: $viewModel.shippingAddress.address2)
                        TextField("Postleitzahl", text: $viewModel.shippingAddress.postcode)
                        TextField("Stadt", text: $viewModel.shippingAddress.city)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            
            Section {
                Button(action: { Task { await viewModel.saveChanges() } }) {
                    HStack {
                        Spacer()
                        Text("Änderungen speichern")
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading || !viewModel.hasChanges)
            }

            Section(header: Text("Passwort ändern")) {
                SecureField("Aktuelles Passwort", text: $currentPassword)
                SecureField("Neues Passwort", text: $newPassword)
                SecureField("Neues Passwort bestätigen", text: $confirmNewPassword)
                
                if let msg = changePasswordErrorMessage { Text(msg).foregroundColor(AppTheme.Colors.error).font(.caption) }
                if let msg = changePasswordSuccessMessage { Text(msg).foregroundColor(AppTheme.Colors.success).font(.caption) }
                
                Button("Passwort speichern") { performPasswordChange() }
                    .disabled(authManager.isLoading || currentPassword.isEmpty || newPassword.isEmpty)
            }
            
            Section(header: Text("Bestellungen")) {
                NavigationLink(destination: OrderListView()) {
                    Text("Meine Bestellungen")
                }
            }
            
            Section {
                Button("Abmelden", role: .destructive) { authManager.logout() }
            }
        }
        .scrollContentBackground(.hidden)
        .onAppear {
            Task {
                await viewModel.fetchProfileData()
            }
        }
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
                currentPassword = ""
                newPassword = ""
                confirmNewPassword = ""
            } catch {
                changePasswordErrorMessage = error.localizedDescription
            }
        }
    }
}
