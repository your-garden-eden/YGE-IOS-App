import Foundation

// MARK: - WooCommerce API Error Enum
enum WooCommerceAPIError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(statusCode: Int, message: String?, errorCode: String?)
    case noData
    // Der .underlying-Fall ist eine gute Ergänzung, um beliebige andere Fehler zu kapseln
    case underlying(Error)
    case decodingError(Error)
    
    // Benutzerfreundliche Beschreibung
    var localizedDescriptionForUser: String {
        switch self {
        case .invalidURL:
            return "Eine ungültige Anfrage wurde gesendet. Bitte versuchen Sie es später erneut."
        case .networkError:
            return "Es gab ein Problem mit Ihrer Netzwerkverbindung. Bitte überprüfen Sie sie und versuchen Sie es erneut."
        case .serverError(let statusCode, let message, _):
            if let msg = message, !msg.isEmpty {
                return msg
            }
            return "Ein Serverfehler ist aufgetreten (Code: \(statusCode)). Bitte versuchen Sie es später erneut."
        case .noData:
            return "Keine Daten vom Server erhalten. Die Anfrage war möglicherweise erfolgreich, aber die Antwort war leer."
        case .underlying(let error):
            return "Ein unerwarteter Fehler ist aufgetreten: \(error.localizedDescription)"
        case .decodingError:
            return "Die Antwort vom Server konnte nicht verarbeitet werden. Bitte versuchen Sie es später erneut."
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
        case .underlying(let error):
            return "WooCommerceAPIError: An underlying error occurred: \(error)"
        case .decodingError(let error):
            return "WooCommerceAPIError: Failed to decode the JSON response. Error: \(error.localizedDescription)"
        }
    }
}

// MARK: - WooCommerce Error Response Struct
// Dieses Struct wird verwendet, um die Fehler-JSON-Antwort von der WooCommerce-API zu parsen.
struct WooCommerceErrorResponse: Decodable, Error {
    let code: String?
    let message: String?
    let data: ErrorData?

    struct ErrorData: Decodable {
        let status: Int?
    }
}
