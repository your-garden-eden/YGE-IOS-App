// YGE-IOS-App/Core/Models/WooCommerce/Shared/WooCommerceErrorResponse.swift
// Oder YGE-IOS-App/Core/Networking/WooCommerceErrors.swift
import Foundation

// --------------------------------------------------------------------------------
// MARK: - WooCommerce Server Error Response Structure
// --------------------------------------------------------------------------------
// Diese Struktur bildet die JSON-Antwort ab, die der WooCommerce-Server bei einem Fehler sendet.
struct WooCommerceErrorResponse: Codable {
    let code: String?        // Z.B. "woocommerce_rest_product_invalid_id", "woocommerce_rest_authentication_error"
    let message: String?     // Menschlich lesbare Fehlermeldung vom Server.
    let data: ErrorResponseData? // Optionale zusätzliche Daten zum Fehler, oft HTTP-Status oder spezifischere Details.

    // Innere Struktur für das 'data'-Feld der Fehlerantwort.
    struct ErrorResponseData: Codable {
        let status: Int? // Der HTTP-Statuscode, den der Server auch im Header gesendet haben sollte.
        // Hier könnten weitere spezifische Felder aus dem 'data'-Objekt der API-Fehlerantwort stehen,
        // z.B. details für Validierungsfehler.
    }
}

// --------------------------------------------------------------------------------
// MARK: - Application's Internal API Error Type
// --------------------------------------------------------------------------------
// Dieser Swift-Fehlertyp wird von deiner Anwendung intern verwendet, um verschiedene
// Arten von Fehlern bei der API-Kommunikation zu repräsentieren und zu handhaben.
// Er wird *nicht* direkt vom Server als JSON gesendet, sondern von deinem Code erzeugt.
enum WooCommerceAPIError: Error {
    case invalidURL                                 // Ein Problem beim Erstellen der Anfrage-URL.
    case networkError(Error)                        // Ein allgemeiner Netzwerkfehler (z.B. keine Verbindung, Timeout), verpackt den originalen Error.
    case decodingError(Error)                       // Ein Fehler beim Parsen/Dekodieren der JSON-Antwort vom Server, verpackt den originalen DecodingError.
    case serverError(statusCode: Int,               // Ein Fehler, den der Server explizit gemeldet hat (z.B. HTTP-Status 4xx, 5xx).
                     message: String?,              // Die optionale Fehlermeldung aus der WooCommerceErrorResponse.
                     errorCode: String?)             // Der optionale Fehlercode-String (z.B. "invalid_product_id") aus der WooCommerceErrorResponse.
    case noData                                     // Die Serverantwort war erfolgreich, aber es kamen keine (erwarteten) Daten zurück.
    case authenticationRequired                     // Ein spezifischer Fehler, wenn Authentifizierung fehlt oder fehlgeschlagen ist.
    case underlying(Error)                          // Ein anderer, nicht näher spezifizierter Fehler, der aufgetreten ist und verpackt wird.
    // Füge hier weitere spezifische Fehlerfälle hinzu, die für deine Anwendungslogik relevant sind.
}

// MARK: - Localized Error Descriptions
// Stellt benutzerfreundliche (oder entwicklerfreundliche) Beschreibungen für WooCommerceAPIError bereit.
extension WooCommerceAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Die angeforderte URL ist ungültig.", comment: "Invalid API URL")
        case .networkError(let underlyingError):
            // Hier könntest du noch prüfen, ob underlyingError ein URLError ist und spezifischere Meldungen ausgeben
            // z.B. für .notConnectedToInternet, .timedOut etc.
            return NSLocalizedString("Netzwerkfehler: \(underlyingError.localizedDescription)", comment: "Network error")
        case .decodingError(let underlyingError):
            var baseMessage = NSLocalizedString("Fehler beim Verarbeiten der Serverantwort.", comment: "Data decoding error")
            if let decodingError = underlyingError as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    baseMessage += " Typkonflikt: \(type) in \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Debug: \(context.debugDescription)"
                case .valueNotFound(let type, let context):
                    baseMessage += " Wert nicht gefunden: \(type) in \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Debug: \(context.debugDescription)"
                case .keyNotFound(let key, let context):
                    baseMessage += " Schlüssel nicht gefunden: \(key.stringValue) in \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Debug: \(context.debugDescription)"
                case .dataCorrupted(let context):
                    baseMessage += " Daten korrupt: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Debug: \(context.debugDescription)"
                @unknown default:
                    baseMessage += " Unbekannter Dekodierungsfehler."
                }
            } else {
                baseMessage += " Details: \(underlyingError.localizedDescription)"
            }
            return baseMessage
        case .serverError(let statusCode, let message, let errorCode):
            var desc = NSLocalizedString("Serverfehler (Status: \(statusCode))", comment: "Server error status code")
            if let msg = message, !msg.isEmpty {
                desc += ": \(msg)"
            } else if let ec = errorCode, !ec.isEmpty {
                desc += " (Fehlercode: \(ec))"
            } else {
                desc += ". Keine weitere Fehlermeldung vom Server."
            }
            return desc
        case .noData:
            return NSLocalizedString("Die Anfrage war erfolgreich, aber der Server hat keine Daten zurückgesendet.", comment: "No data from server")
        case .authenticationRequired:
            return NSLocalizedString("Authentifizierung ist fehlgeschlagen oder erforderlich. Bitte erneut anmelden oder Zugriffsrechte prüfen.", comment: "Authentication required or failed")
        case .underlying(let underlyingError):
            return NSLocalizedString("Ein interner Anwendungsfehler ist aufgetreten: \(underlyingError.localizedDescription)", comment: "Underlying application error")
        }
    }
}
