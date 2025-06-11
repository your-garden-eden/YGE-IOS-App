import Foundation

// MARK: - WooCommerce API Error Enum
enum WooCommerceAPIError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(statusCode: Int, message: String?, errorCode: String?)
    case noData
    case decodingError(Error)
    case productNotFound
    
    // --- KORREKTUR: Der fehlende Fehlerfall wird hier hinzugefügt ---
    case internalError(String)
    
    case underlying(Error)

    // Benutzerfreundliche Beschreibung
    var localizedDescriptionForUser: String {
        switch self {
        case .invalidURL:
            return "Eine ungültige Anfrage wurde gesendet. Bitte versuchen Sie es später erneut."
        case .networkError:
            return "Es gab ein Problem mit Ihrer Netzwerkverbindung. Bitte überprüfen Sie sie und versuchen Sie es erneut."
        case .serverError(let statusCode, let message, _):
            if let msg = message, !msg.isEmpty { return msg }
            return "Ein Serverfehler ist aufgetreten (Code: \(statusCode)). Bitte versuchen Sie es später erneut."
        case .noData:
            return "Keine Daten vom Server erhalten. Die Anfrage war möglicherweise erfolgreich, aber die Antwort war leer."
        case .decodingError:
            return "Die Antwort vom Server konnte nicht verarbeitet werden. Bitte versuchen Sie es später erneut."
        case .productNotFound:
            return "Das gesuchte Produkt konnte leider nicht gefunden werden."
            
        // --- KORREKTUR: Benutzerfreundliche Nachricht für den neuen Fall ---
        case .internalError(let message):
            // Diese Nachricht sollte idealerweise nicht dem Benutzer angezeigt werden,
            // aber wir geben eine generische Meldung als Fallback.
            print("Internal Error Occurred: \(message)")
            return "Ein interner Fehler in der App ist aufgetreten. Bitte starten Sie die App neu."
            
        case .underlying(let error):
            return "Ein unerwarteter Fehler ist aufgetreten: \(error.localizedDescription)"
        }
    }
    
    // Detaillierte Beschreibung für Entwickler-Logs
    var debugDescription: String {
        switch self {
        case .invalidURL:
            return "WooCommerceAPIError: The constructed URL was invalid."
        case .networkError(let error):
            return "WooCommerceAPIError: Network request failed with error: \(error.localizedDescription)"
        case .serverError(let statusCode, let message, let errorCode):
            let msg = message ?? "No message"
            let code = errorCode ?? "No error code"
            return "WooCommerceAPIError: Server returned status \(statusCode) with code '\(code)' and message: '\(msg)'"
        case .noData:
            return "WooCommerceAPIError: The server responded with success, but returned no data."
        case .decodingError(let error):
            return "WooCommerceAPIError: Failed to decode the JSON response. Error: \(error.localizedDescription)"
        case .productNotFound:
            return "WooCommerceAPIError: Product not found. The API call for a specific resource (e.g., by slug) returned no product."
            
        // --- KORREKTUR: Debug-Beschreibung für den neuen Fall ---
        case .internalError(let message):
            return "WooCommerceAPIError: An internal logic error occurred: \(message)"
            
        case .underlying(let error):
            return "WooCommerceAPIError: An underlying error occurred: \(error)"
        }
    }
}

// MARK: - WooCommerce Error Response Struct
struct WooCommerceErrorResponse: Decodable, Error {
    let code: String?
    let message: String?
    let data: ErrorData?

    struct ErrorData: Decodable {
        let status: Int?
    }
}
