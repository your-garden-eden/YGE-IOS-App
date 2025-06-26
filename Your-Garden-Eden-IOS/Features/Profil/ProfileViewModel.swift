// DATEI: ProfileViewModel.swift
// PFAD: Features/Profile/ViewModels/ProfileViewModel.swift
// VERSION: 3.5 (VERBESSERT)
// STATUS: Erfolgsmeldung blendet sich nach 10 Sekunden automatisch aus.

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var billingAddress = UserAddress()
    @Published var shippingAddress = UserAddress()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let profileAPIManager = ProfileAPIManager.shared
    private let localProfileStorage = LocalProfileStorage()
    private let logger = LogSentinel.shared
    
    // Task, der die Erfolgsmeldung nach einer Verzögerung ausblendet.
    private var clearSuccessMessageTask: Task<Void, Never>?

    init() {
        if let localAddresses = localProfileStorage.loadAddresses() {
            self.billingAddress = localAddresses.billing
            self.shippingAddress = localAddresses.shipping
        }
    }

    func fetchProfileDataIfNeeded() async {
        // Nur laden, wenn die Adressen leer sind (z.B. bei der ersten Anmeldung)
        guard billingAddress.firstName?.isEmpty ?? true else { return }
        
        isLoading = true; errorMessage = nil; successMessage = nil; defer { isLoading = false }
        logger.info("Keine lokalen Adressdaten. Beginne Abruf vom Server.")
        
        do {
            let serverAddresses = try await profileAPIManager.fetchProfileAndAddresses()
            self.billingAddress = serverAddresses.billing
            self.shippingAddress = serverAddresses.shipping
            localProfileStorage.saveAddresses(serverAddresses)
            logger.info("Profil- und Adressdaten erfolgreich vom Server geladen.")
        } catch {
            errorMessage = "Adressdaten konnten nicht geladen werden."
            logger.error("Fehler beim Abrufen der Adressdaten: \(error.localizedDescription)")
        }
    }
    
    // Vereinfachte Speicherfunktion, die die neuen Daten von der View erhält.
    func updateAddresses(billing: UserAddress, shipping: UserAddress) async {
        isLoading = true
        // Breche einen alten Task zum Ausblenden ab, falls vorhanden.
        clearSuccessMessageTask?.cancel()
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }
        
        let payload = UserAddressesResponse(billing: billing, shipping: shipping)
        
        // Lokal speichern für Offline-Verfügbarkeit
        localProfileStorage.saveAddresses(payload)
        
        do {
            let response = try await profileAPIManager.updateProfileAndAddresses(payload: payload)
            
            // Nach erfolgreichem Server-Sync die Properties des ViewModels aktualisieren.
            self.billingAddress = billing
            self.shippingAddress = shipping
            
            self.successMessage = response.message
            logger.info("Server-Sync erfolgreich: \(response.message)")
            
            // Starte einen neuen Task, um die Nachricht nach 10 Sekunden auszublenden.
            clearSuccessMessageTask = Task {
                do {
                    try await Task.sleep(for: .seconds(10))
                    // Stelle sicher, dass die Aktualisierung auf dem Main-Thread geschieht.
                    await MainActor.run {
                        self.successMessage = nil
                    }
                } catch {
                    // Der Task wurde abgebrochen (z.B. durch einen neuen Speicherversuch),
                    // also tun wir nichts.
                    logger.info("Task zum Ausblenden der Erfolgsmeldung wurde abgebrochen.")
                }
            }
            
        } catch {
            errorMessage = "Lokal gespeichert, aber Server-Sync fehlgeschlagen. Bitte versuchen Sie es erneut."
            logger.error("Fehler bei der Adress-Synchronisation: \(error.localizedDescription)")
        }
    }
}
