// DATEI: ProfileAPIManager.swift
// PFAD: Manager/ProfileAPIManager.swift
// VERSION: STAMMDATEN 1.3 - CONCURRENCY-SAFE
// STATUS: MODIFIZIERT & FINALISIERT

import Foundation

// KORREKTUR: Die Klasse wird dem Main Actor zugeordnet, um Thread-sicheren
// Zugriff auf den ebenfalls Main-Actor-isolierten WooCommerceAPIManager zu gewährleisten.
@MainActor
class ProfileAPIManager {
    
    static let shared = ProfileAPIManager()
    private let apiManager = WooCommerceAPIManager.shared
    
    private init() {}

    func fetchProfileAndAddresses() async throws -> UserAddressesResponse {
        return try await apiManager.performCustomAuthenticatedRequest(
            urlString: AppConfig.API.YGE.userAddresses,
            method: "GET",
            body: nil,
            responseType: UserAddressesResponse.self
        )
    }
    
    func updateProfileAndAddresses(payload: UserAddressesResponse) async throws -> SuccessResponse {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let bodyData = try encoder.encode(payload)
        
        return try await apiManager.performCustomAuthenticatedRequest(
            urlString: AppConfig.API.YGE.userAddresses,
            method: "POST",
            body: bodyData,
            responseType: SuccessResponse.self
        )
    }
}
