// DATEI: ProfileViews.swift
// PFAD: Features/Profile/Views/ProfileViews.swift
// VERSION: 1.3 (ÜBERARBEITET)
// STATUS: "Bearbeiten"-Modus für Adressen implementiert.

import SwiftUI

// MARK: - ProfilView
struct ProfilView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var showingAuthSheet = false
    @State private var isEditing = false
    
    // Lokale Zustände für die Bearbeitung, um das ViewModel nicht direkt zu verändern.
    @State private var editedBillingAddress = UserAddress()
    @State private var editedShippingAddress = UserAddress()
    @State private var editedCopyBillingToShipping = false

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            if authManager.isLoggedIn {
                loggedInProfile
            } else {
                guestProfile
            }
        }
        .navigationTitle("Mein Profil")
        .sheet(isPresented: $showingAuthSheet) {
            AuthContainerView(onDismiss: { self.showingAuthSheet = false })
        }
        .task {
            if authManager.isLoggedIn {
                await viewModel.fetchProfileDataIfNeeded()
            }
        }
        .onReceive(viewModel.$billingAddress) { newAddress in
            // Wenn das ViewModel neue Daten lädt, aktualisieren wir unsere lokalen Kopien.
            if !isEditing {
                self.editedBillingAddress = newAddress
            }
        }
        .onReceive(viewModel.$shippingAddress) { newAddress in
            if !isEditing {
                self.editedShippingAddress = newAddress
            }
        }
    }

    @ViewBuilder
    private var loggedInProfile: some View {
        Form {
            addressSection
            
            if let message = viewModel.successMessage {
                Section { Text(message).foregroundColor(AppTheme.Colors.success) }
            }
            if let message = viewModel.errorMessage {
                Section { Text(message).foregroundColor(AppTheme.Colors.error) }
            }

            Section("Konto") {
                NavigationLink("Meine Bestellungen") { OrderListView() }
            }

            Section {
                Button("Abmelden", role: .destructive) {
                    authManager.logout()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .disabled(viewModel.isLoading)
        .overlay {
            if viewModel.isLoading {
                LoadingOverlayView()
            }
        }
    }
    
    // Gekapselte Sektion für Adressen mit Bearbeiten-Modus
    private var addressSection: some View {
        Section(header: Text("Adressen")) {
            if isEditing {
                // Bearbeitungsmodus
                AddressEditor(title: "Rechnungsadresse", address: $editedBillingAddress)
                Toggle("Lieferadresse ist gleich", isOn: $editedCopyBillingToShipping.animation())
                if !editedCopyBillingToShipping {
                    AddressEditor(title: "Lieferadresse", address: $editedShippingAddress)
                }
                
                HStack {
                    Button("Abbrechen", role: .cancel) {
                        // Änderungen verwerfen und Modus beenden
                        isEditing = false
                        resetLocalEdits()
                    }
                    Spacer()
                    Button("Speichern") {
                        Task {
                            let shipping = editedCopyBillingToShipping ? editedBillingAddress : editedShippingAddress
                            await viewModel.updateAddresses(billing: editedBillingAddress, shipping: shipping)
                            isEditing = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            } else {
                // Ansichtsmodus
                AddressDisplayView(title: "Rechnungsadresse", address: viewModel.billingAddress)
                AddressDisplayView(title: "Lieferadresse", address: viewModel.shippingAddress)
                
                Button(action: {
                    // Lokale Kopien für die Bearbeitung erstellen und Modus starten
                    resetLocalEdits()
                    isEditing = true
                }) {
                    Label("Adressen ändern", systemImage: "pencil")
                }
            }
        }
        .onChange(of: editedBillingAddress) { _, newBillingAddress in
            if editedCopyBillingToShipping {
                editedShippingAddress = newBillingAddress
            }
        }
    }
    
    private func resetLocalEdits() {
        editedBillingAddress = viewModel.billingAddress
        editedShippingAddress = viewModel.shippingAddress
        // Sinnvoller Standardwert für den Toggle beim Start der Bearbeitung
        editedCopyBillingToShipping = (viewModel.billingAddress == viewModel.shippingAddress)
    }
    
    private var guestProfile: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textMuted)
            Text("Anmelden für Profil")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h5, weight: .bold))
            Text("Melde dich an, um deine Adressen und Bestellungen zu verwalten.")
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.Colors.textMuted)
            Button("Anmelden / Registrieren") {
                self.showingAuthSheet = true
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .padding(.top)
        }.padding()
    }
}

// Neue View zur reinen Anzeige von Adressen
struct AddressDisplayView: View {
    let title: String
    let address: UserAddress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline).padding(.bottom, 2)
            
            if (address.firstName?.isEmpty ?? true) && (address.lastName?.isEmpty ?? true) {
                Text("Keine Adressdaten vorhanden.")
                    .foregroundColor(.secondary)
            } else {
                Text("\(address.firstName ?? "") \(address.lastName ?? "")")
                Text(address.address1 ?? "")
                Text("\(address.postcode ?? "") \(address.city ?? "")")
            }
        }
        .padding(.vertical, 4)
    }
}


struct AddressEditor: View {
    let title: String
    @Binding var address: UserAddress
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            TextField("Vorname", text: Binding($address.firstName, default: ""))
            TextField("Nachname", text: Binding($address.lastName, default: ""))
            TextField("Straße & Nr.", text: Binding($address.address1, default: ""))
            TextField("Postleitzahl", text: Binding($address.postcode, default: ""))
            TextField("Stadt", text: Binding($address.city, default: ""))
        }
        .textFieldStyle(PlainTextFieldStyle())
    }
}

// MARK: - OrderListView
struct OrderListView: View {
    @StateObject private var viewModel = OrderListViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(AppTheme.Colors.error).padding()
            } else if viewModel.orders.isEmpty {
                Text("Sie haben noch keine Bestellungen.").foregroundColor(AppTheme.Colors.textMuted)
            } else {
                List {
                    ForEach(viewModel.orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderRow(order: order)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Meine Bestellungen")
        .customBackButton()
        .task { await viewModel.fetchOrders() }
    }
}

// MARK: - OrderRow
struct OrderRow: View {
    let order: WooCommerceOrder
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Bestellung #\(order.number)").font(.headline)
                Spacer()
                Text("\(order.total) \(order.currency)").font(.headline.weight(.semibold)).foregroundColor(AppTheme.Colors.primary)
            }
            Text("Datum: \(formattedDate(from: order.date_created))").font(.subheadline).foregroundColor(.secondary)
            Text("Status: \(order.status.capitalized)").font(.subheadline.weight(.medium)).foregroundColor(.secondary)
        }.padding(.vertical, 8)
    }
    
    private func formattedDate(from dateString: String?) -> String {
        guard let dateString = dateString, !dateString.isEmpty else { return "Unbekannt" }
        let formatter = ISO8601DateFormatter();
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) { return date.formatted(date: .long, time: .omitted) }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) { return date.formatted(date: .long, time: .omitted) }
        return dateString
    }
}

// MARK: - OrderDetailView
struct OrderDetailView: View {
    let order: WooCommerceOrder
    var body: some View {
        List {
            Section("Übersicht") {
                InfoRow(label: "Bestellnummer", value: order.number)
                InfoRow(label: "Datum", value: formattedDate(from: order.date_created ?? ""))
                InfoRow(label: "Status", value: order.status.capitalized)
                InfoRow(label: "Zahlung", value: order.payment_method_title)
                InfoRow(label: "Gesamt", value: "\(order.total) \(order.currency)")
            }
            Section("Artikel (\(order.line_items.count))") {
                ForEach(order.line_items) { item in
                    LineItemRow(item: item, currencySymbol: currencySymbol(for: order.currency))
                }
            }
            Section("Lieferadresse") { Text(formatAddress(order.shipping)) }
            Section("Rechnungsadresse") { Text(formatAddress(order.billing)) }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationTitle("Bestellung #\(order.number)")
        .customBackButton()
    }
    
    private func formatAddress(_ address: ShippingAddress) -> String {
        let components = [
            "\(address.first_name ?? "") \(address.last_name ?? "")".trimmingCharacters(in: .whitespaces),
            address.company, address.address_1, address.address_2,
            "\(address.postcode ?? "") \(address.city ?? "")".trimmingCharacters(in: .whitespaces),
            address.country
        ].compactMap{$0}.filter{!$0.isEmpty}
        return components.joined(separator: "\n")
    }
    
    private func formatAddress(_ address: BillingAddress) -> String {
        let components = [
            "\(address.first_name ?? "") \(address.last_name ?? "")".trimmingCharacters(in: .whitespaces),
            address.company, address.address_1, address.address_2,
            "\(address.postcode ?? "") \(address.city ?? "")".trimmingCharacters(in: .whitespaces),
            address.country
        ].compactMap{$0}.filter{!$0.isEmpty}
        return components.joined(separator: "\n")
    }
    
    private func formattedDate(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) { return date.formatted(date: .long, time: .shortened) }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) { return date.formatted(date: .long, time: .shortened) }
        return dateString
    }
    
    private func currencySymbol(for code: String) -> String {
        return NSLocale(localeIdentifier: code).displayName(forKey: .currencySymbol, value: code) ?? code
    }
}

// MARK: - InfoRow & LineItemRow
struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(.secondary).multilineTextAlignment(.trailing)
        }
    }
}

struct LineItemRow: View {
    let item: WooCommerceOrderLineItem
    let currencySymbol: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name).bold()
                Text("Menge: \(item.quantity)").foregroundColor(.secondary)
            }
            Spacer()
            Text("\(String(format: "%.2f", item.price * Double(item.quantity))) \(currencySymbol)")
        }.padding(.vertical, 4)
    }
}

// Binding Helper
extension Binding {
    init(_ source: Binding<Value?>, default value: Value) {
        self.init(get: { source.wrappedValue ?? value }, set: { source.wrappedValue = $0 })
    }
}
