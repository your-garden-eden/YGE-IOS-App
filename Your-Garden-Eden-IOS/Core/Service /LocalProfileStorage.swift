//
//  LocalProfileStorage.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 25.06.25.
//


// DATEI: LocalProfileStorage.swift
// PFAD: Services/Storage/LocalProfileStorage.swift
// VERSION: 1.0 (NEU ERSTELLT & FINAL)
// STATUS: Einsatzbereit.

import Foundation

struct LocalProfileStorage {
    private static let userAddressesKey = "com.yourgardeneden.userAddresses"
    private let userDefaults = UserDefaults.standard
    private let logger = LogSentinel.shared

    func saveAddresses(_ addresses: UserAddressesResponse) {
        do {
            let data = try JSONEncoder().encode(addresses)
            userDefaults.set(data, forKey: Self.userAddressesKey)
            logger.info("Benutzeradressen erfolgreich lokal gespeichert.")
        } catch {
            logger.error("Fehler beim Kodieren und Speichern der Adressen: \(error.localizedDescription)")
        }
    }

    func loadAddresses() -> UserAddressesResponse? {
        guard let data = userDefaults.data(forKey: Self.userAddressesKey) else {
            logger.notice("Keine lokalen Adressdaten gefunden.")
            return nil
        }
        
        do {
            let addresses = try JSONDecoder().decode(UserAddressesResponse.self, from: data)
            logger.info("Benutzeradressen erfolgreich aus lokalem Speicher geladen.")
            return addresses
        } catch {
            logger.error("Fehler beim Dekodieren der lokalen Adressen: \(error.localizedDescription)")
            clearAddresses()
            return nil
        }
    }
    
    func clearAddresses() {
        userDefaults.removeObject(forKey: Self.userAddressesKey)
        logger.info("Lokale Adressdaten erfolgreich entfernt.")
    }
}