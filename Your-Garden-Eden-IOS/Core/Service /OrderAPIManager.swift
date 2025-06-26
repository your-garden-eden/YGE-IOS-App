// DATEI: OrderAPIManager.swift
// PFAD: Features/Profile/Services/OrderAPIManager.swift
// VERSION: 1.1 (ÜBERARBEITET)
// STATUS: Umgestellt auf den neuen, sicheren benutzerdefinierten Endpunkt.

import Foundation

@MainActor
public class OrderAPIManager {
    public static let shared = OrderAPIManager()
    private let authManager = AuthManager.shared
    private let logger = LogSentinel.shared
    
    private init() {}

    // Die Funktion benötigt keine Kunden-ID mehr.
    public func fetchOrders() async throws -> [WooCommerceOrder] {
        logger.info("Rufe Bestellungen für den aktuellen Benutzer über den benutzerdefinierten Endpunkt ab...")
        // Ruft den neuen, sicheren Endpunkt auf.
        return try await performYGEAuthenticatedRequest(endpoint: AppConfig.API.YGE.userOrders, method: "GET")
    }
    
    // Private Hilfsfunktion für authentifizierte Anfragen, ähnlich wie im ProfileAPIManager.
    private func performYGEAuthenticatedRequest<T: Decodable>(endpoint: String, method: String) async throws -> T {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        guard let token = authManager.getAuthToken() else {
            throw WooCommerceAPIError.notAuthenticated
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.invalidURL
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let err = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
            logger.error("OrderAPI Error [\(httpResponse.statusCode)] auf \(request.url?.path() ?? "N/A"): \(err?.message ?? "N/A")")
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
