// DATEI: WooCommerceErrorModels.swift
// PFAD: Core/Models/WooCommerceErrorModels.swift
// VERSION: 1.0 (FINAL)
// STATUS: GEPRÜFT & BESTÄTIGT

import Foundation

public enum WooCommerceAPIError: Error, LocalizedError {
    case invalidURL
    case notAuthenticated
    case noData
    case productNotFound
    case serverError(statusCode: Int, message: String?, errorCode: String?)
    case decodingError(Error)
    case underlying(Error)

    public var localizedDescriptionForUser: String {
        switch self {
        case .notAuthenticated: return "Sitzung abgelaufen. Bitte erneut anmelden."
        case .productNotFound: return "Das angeforderte Produkt konnte nicht gefunden werden."
        case .serverError(_, let msg, let code):
            let cleanedMessage = msg?.strippingHTML() ?? "Ein Serverfehler ist aufgetreten."
            if code == "woocommerce_rest_invalid_coupon" {
                return "Der Gutscheincode ist ungültig oder abgelaufen."
            }
            return cleanedMessage
        default: return "Ein unerwarteter technischer Fehler ist aufgetreten."
        }
    }
}

public struct WooCommerceErrorResponse: Decodable {
    public let code: String
    public let message: String
    public let data: ErrorData?
    
    public struct ErrorData: Decodable {
        public let status: Int
    }
}
