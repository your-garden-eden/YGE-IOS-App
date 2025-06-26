// DATEI: ProfileAPIManager.swift
// PFAD: Features/Profile/Services/ProfileAPIManager.swift
// VERSION: 1.1 (REPARIERT)
// STATUS: Serialisierungs- und Deserialisierungslogik korrigiert.

import Foundation

@MainActor
public class ProfileAPIManager {
    public static let shared = ProfileAPIManager()
    private let logger = LogSentinel.shared
    
    private init() {}

    public func fetchProfileAndAddresses() async throws -> UserAddressesResponse {
        // Ruft die neue, korrekte Funktion für GET-Anfragen ohne Body auf.
        return try await performYGEAuthenticatedRequest(endpoint: AppConfig.API.YGE.userAddresses, method: "GET")
    }
    
    public func updateProfileAndAddresses(payload: UserAddressesResponse) async throws -> SuccessResponse {
        // Ruft die neue, korrekte Funktion für POST-Anfragen mit Body auf.
        return try await performYGEAuthenticatedRequest(endpoint: AppConfig.API.YGE.userAddresses, method: "POST", body: payload)
    }
    
    private func performYGEAuthenticatedRequest<T: Decodable, B: Encodable>(endpoint: String, method: String, body: B) async throws -> T {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)
        
        return try await executeAndDecode(request: request)
    }
    
    private func performYGEAuthenticatedRequest<T: Decodable>(endpoint: String, method: String) async throws -> T {
        guard let url = URL(string: endpoint) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        return try await executeAndDecode(request: request)
    }

    private func executeAndDecode<T: Decodable>(request: URLRequest) async throws -> T {
        var mutableRequest = request
        guard let token = AuthManager.shared.getAuthToken() else { throw WooCommerceAPIError.notAuthenticated }
        mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: mutableRequest)
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.invalidURL }

        guard (200...299).contains(httpResponse.statusCode) else {
            let err = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
            logger.error("ProfileAPI Error [\(httpResponse.statusCode)] auf \(mutableRequest.url?.path() ?? "N/A"): \(err?.message ?? "N/A")")
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: err?.message, errorCode: err?.code)
        }
        
        if data.isEmpty && T.self == SuccessResponse.self {
            return SuccessResponse(success: true, message: "Operation erfolgreich.") as! T
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
