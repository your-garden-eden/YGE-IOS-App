// YGE-IOS-App/Core/Managers/WooCommerceAPIManager.swift
import Foundation

// Eigener Fehlertyp für den APIManager
enum WooCommerceAPIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?) // Für HTTP Fehler
    case noData
    case authenticationRequired // Falls wir merken, dass Auth fehlt
    case underlying(Error)
}

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()

    private let coreApiBaseURL = AppConfig.WooCommerce.coreApiBaseURL // Aus AppConfig
    private let session: URLSession

    init() {
        print("WooCommerceAPIManager initialized (REAL API MODE)")
        let config = URLSessionConfiguration.default
        // Hier könnten Header für alle Requests gesetzt werden, falls nötig
        self.session = URLSession(configuration: config)
    }

    // MARK: - Category Functions
    func getCategories(
        parent: Int? = nil,
        perPage: Int = 100,
        page: Int = 1,
        hideEmpty: Bool = true,
        orderby: String = "menu_order",
        order: String = "asc"
        // completion: @escaping (Result<[WooCommerceCategory], WooCommerceAPIError>) -> Void // Alte Signatur
    ) async throws -> [WooCommerceCategory] { // Neue async/throws Signatur
        var urlComponents = URLComponents(string: coreApiBaseURL + "products/categories")
        if urlComponents == nil { throw WooCommerceAPIError.invalidURL }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "hide_empty", value: String(hideEmpty)),
            URLQueryItem(name: "orderby", value: orderby),
            URLQueryItem(name: "order", value: order)
        ]
        if let parentId = parent {
            queryItems.append(URLQueryItem(name: "parent", value: String(parentId)))
        }

        // --- HIER DIE AUTHENTIFIZIERUNGSFRAGE ---
        // Wenn consumer_key/secret nötig SIND (Option 3 - nicht empfohlen):
        // queryItems.append(URLQueryItem(name: "consumer_key", value: "DEIN_KEY_FALLS_UNBEDINGT_NOETIG"))
        // queryItems.append(URLQueryItem(name: "consumer_secret", value: "DEIN_SECRET_FALLS_UNBEDINGT_NOETIG"))
        // -----------------------------------------

        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            throw WooCommerceAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Hier ggf. weitere Header setzen

        print("WooCommerceAPIManager: Fetching categories from URL: \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw WooCommerceAPIError.networkError(NSError(domain: "WooCommerceAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]))
            }

            if !(200...299).contains(httpResponse.statusCode) {
                // Versuche, eine Fehlermeldung aus dem Body zu parsen
                var errorMessage: String?
                if let errorData = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                    errorMessage = errorData.message
                }
                print("WooCommerceAPIManager: Server error \(httpResponse.statusCode) for \(url.absoluteString). Message: \(errorMessage ?? "N/A")")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            let decoder = JSONDecoder()
            // Ggf. Key-Decoding-Strategie setzen, wenn JSON Keys anders sind als Swift-Properties
            // decoder.keyDecodingStrategy = .convertFromSnakeCase // Wenn nötig

            let categories = try decoder.decode([WooCommerceCategory].self, from: data) // Hier dein Swift-Modell
            return categories
        } catch let error as DecodingError {
            print("WooCommerceAPIManager: Decoding error for \(url.absoluteString): \(error)")
            throw WooCommerceAPIError.decodingError(error)
        } catch let error as WooCommerceAPIError {
            throw error // Bereits ein WooCommerceAPIError
        } catch {
            print("WooCommerceAPIManager: Network or other error for \(url.absoluteString): \(error)")
            throw WooCommerceAPIError.networkError(error)
        }
    }

    // Dummy-Struct für Fehlermeldungen von WooCommerce (kann erweitert werden)
    struct WooCommerceErrorResponse: Codable {
        let code: String?
        let message: String?
        let data: ErrorData?

        struct ErrorData: Codable {
            let status: Int?
        }
    }

    // Weitere Methoden für Produkte etc. folgen hier...
    // z.B. func getProducts(categoryId: Int?, ...) async throws -> WooCommerceProductsResponseContainer
    // (WooCommerceProductsResponseContainer wäre ein Struct, das Produkte und Paginierungs-Header enthält)
}
