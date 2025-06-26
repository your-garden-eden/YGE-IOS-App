// DATEI: OrderListViewModel.swift
// PFAD: Features/Profile/ViewModels/OrderListViewModel.swift
// VERSION: 1.1 (VEREINFACHT)
// STATUS: An den neuen OrderAPIManager angepasst.

import Foundation

@MainActor
class OrderListViewModel: ObservableObject {
    @Published var orders: [WooCommerceOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let orderAPIManager = OrderAPIManager.shared
    private let logger = LogSentinel.shared
    private let authManager = AuthManager.shared

    func fetchOrders() async {
        // Die Abfrage der Kunden-ID ist nicht mehr nötig für den API-Aufruf,
        // dient aber als gute Prüfung, ob überhaupt ein Benutzer angemeldet ist.
        guard authManager.isLoggedIn else {
            errorMessage = "Bitte melden Sie sich an, um Ihre Bestellungen zu sehen."
            logger.error("Bestellabruf fehlgeschlagen: Benutzer ist nicht angemeldet.")
            return
        }
        
        isLoading = true
        errorMessage = nil
        logger.info("Beginne Abruf der Bestellhistorie für den aktuellen Benutzer.")
        
        do {
            // Der Aufruf benötigt keine Kunden-ID mehr.
            orders = try await orderAPIManager.fetchOrders()
            logger.info("\(orders.count) Bestellungen erfolgreich geladen.")
        } catch {
            errorMessage = "Ihre Bestellungen konnten nicht geladen werden."
            logger.error("Fehler beim Laden der Bestellhistorie: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
