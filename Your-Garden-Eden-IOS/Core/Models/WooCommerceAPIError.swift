//
//  WooCommerceAPIError.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: ErrorModels.swift
// PFAD: Models/ErrorModels.swift
// ZWECK: Definiert benutzerdefinierte Fehler-Enums und dekodierbare
//        Fehler-Antworten von den APIs.

import Foundation

public enum WooCommerceAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case productNotFound
    case notAuthenticated
    case serverError(statusCode: Int, message: String?, errorCode: String?)
    case decodingError(Error)
    case underlying(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Die API-Adresse ist ungültig."
        case .noData: return "Keine Daten vom Server erhalten."
        case .productNotFound: return "Das Produkt wurde nicht gefunden."
        case .notAuthenticated: return "Authentifizierung fehlgeschlagen. Bitte erneut anmelden."
        case .serverError(let st, let msg, let code): return "Serverfehler (\(st)): \(msg ?? "Unbekannt") (\(code ?? "N/A"))"
        case .decodingError(let err):
            let nsError = err as NSError
            return "Decoding Fehler: \(err.localizedDescription) - userInfo: \(nsError.userInfo)"
        case .underlying(let err): return "Ein unerwarteter Fehler ist aufgetreten: \(err.localizedDescription)"
        }
    }
    
    public var localizedDescriptionForUser: String {
        switch self {
        case .invalidURL, .noData, .decodingError: return "Ein Problem mit der Serververbindung ist aufgetreten."
        case .productNotFound: return "Das angeforderte Produkt konnte nicht gefunden werden."
        case .notAuthenticated: return "Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an."
        case .serverError(_, let msg, _): return msg ?? "Ein Fehler auf dem Server ist aufgetreten. Unser Team wurde informiert."
        case .underlying: return "Ein unerwarteter Fehler ist aufgetreten. Bitte starten Sie die App neu."
        }
    }
}

public struct WooCommerceErrorResponse: Decodable {
    public let code: String
    public let message: String
}

public struct WooCommerceStoreErrorResponse: Decodable {
    public let code: String
    public let message: String
}