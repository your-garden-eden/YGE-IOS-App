// DATEI: ProfileViewModel.swift
// PFAD: Features/Profile/ViewModels/ProfileViewModel.swift
// VERSION: STAMMDATEN 1.0
// STATUS: NEU

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties for UI Binding
    @Published var billingAddress = UserAddress()
    @Published var shippingAddress = UserAddress()
    @Published var copyBillingToShipping = false {
        didSet {
            if copyBillingToShipping {
                shippingAddress = billingAddress
            }
        }
    }
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Private Properties
    private let profileAPIManager = ProfileAPIManager.shared
    private var originalAddresses: UserAddressesResponse?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var hasChanges: Bool {
        guard let original = originalAddresses else { return false }
        let current = UserAddressesResponse(billing: billingAddress, shipping: shippingAddress)
        return original != current
    }

    // MARK: - Initialization
    init() {
        setupAddressSync()
    }
    
    // Synchronisiert die Lieferadresse mit der Rechnungsadresse, wenn der Schalter aktiv ist.
    private func setupAddressSync() {
        $billingAddress
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] newBillingAddress in
                guard let self = self, self.copyBillingToShipping else { return }
                self.shippingAddress = newBillingAddress
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods
    
    /// Lädt die Profil- und Adressdaten vom Server.
    func fetchProfileData() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let addresses = try await profileAPIManager.fetchProfileAndAddresses()
            self.billingAddress = addresses.billing
            self.shippingAddress = addresses.shipping
            self.originalAddresses = addresses // Speichert den Originalzustand für den "hasChanges"-Vergleich.
        } catch let apiError as WooCommerceAPIError {
            errorMessage = apiError.localizedDescriptionForUser
        } catch {
            errorMessage = "Ein unerwarteter Fehler ist aufgetreten: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Speichert die geänderten Daten auf dem Server.
    func saveChanges() async {
        guard hasChanges else {
            successMessage = "Keine Änderungen zum Speichern vorhanden."
            // Nachricht nach kurzer Zeit ausblenden
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if self.successMessage == "Keine Änderungen zum Speichern vorhanden." {
                    self.successMessage = nil
                }
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let payload = UserAddressesResponse(billing: billingAddress, shipping: shippingAddress)
        
        do {
            let response = try await profileAPIManager.updateProfileAndAddresses(payload: payload)
            // Nach erfolgreichem Speichern den neuen Zustand als "original" setzen.
            self.originalAddresses = payload
            self.successMessage = response.message
        } catch let apiError as WooCommerceAPIError {
            errorMessage = apiError.localizedDescriptionForUser
        } catch {
            errorMessage = "Ein unerwarteter Fehler ist aufgetreten: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
