// YGE-IOS-App/Core/Managers/WooCommerceAPIManager.swift

import Foundation

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()

    // Zugriff auf die URLs aus AppConfig
    private let coreApiBaseURL = AppConfig.WooCommerce.coreApiBaseURL
    private let session: URLSession

    // Beispiel für Consumer Key/Secret - ERSETZE DIESE DURCH DEINE ECHTEN KEYS
    // Idealerweise sollten diese nicht hartcodiert sein, sondern sicher verwaltet werden.
    // Für dieses Beispiel nehmen wir an, du hast sie hier temporär für Testzwecke.
    private let consumerKey = "ck_764caa58c2fd1cc7a0ad705630b3f8f2ea397dad"
    private let consumerSecret = "cs_5ca3357f994013428fb5028baa3bfc8f33e4f969"

    init() {
        print("WooCommerceAPIManager initialized (REAL API MODE)")
        let config = URLSessionConfiguration.default
        // Hier könnten Header für alle Requests gesetzt werden, falls nötig
        self.session = URLSession(configuration: config)
    }

    // MARK: - Helper für Authentifizierung
    private func addAuthQueryItems(to items: [URLQueryItem]) -> [URLQueryItem] {
        var newItems = items
        newItems.append(URLQueryItem(name: "consumer_key", value: self.consumerKey))
        newItems.append(URLQueryItem(name: "consumer_secret", value: self.consumerSecret))
        return newItems
    }

    // MARK: - Category Functions
    func getCategories(
        parent: Int? = nil,
        perPage: Int = 100,
        page: Int = 1,
        hideEmpty: Bool = true,
        orderby: String = "menu_order",
        order: String = "asc"
    ) async throws -> [WooCommerceCategory] {
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
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems) // Auth hinzufügen

        guard let url = urlComponents?.url else {
            throw WooCommerceAPIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print("WooCommerceAPIManager: Fetching categories from URL: \(url.absoluteString)")
        return try await performRequest(request: request, decodingType: [WooCommerceCategory].self, functionNameForLog: "getCategories")
    }

    // MARK: - Product Functions
    func getProducts(
        categoryId: Int? = nil,
        perPage: Int = 10,
        page: Int = 1,
        searchQuery: String? = nil,
        featured: Bool? = nil,
        onSale: Bool? = nil,
        orderBy: String = "date",
        order: String = "desc"
    ) async throws -> WooCommerceProductsResponseContainer {
        var urlComponents = URLComponents(string: coreApiBaseURL + "products")
        if urlComponents == nil { throw WooCommerceAPIError.invalidURL }

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "orderby", value: orderBy),
            URLQueryItem(name: "order", value: order)
        ]
        if let catId = categoryId { queryItems.append(URLQueryItem(name: "category", value: String(catId))) }
        if let searchQuery = searchQuery, !searchQuery.isEmpty { queryItems.append(URLQueryItem(name: "search", value: searchQuery)) }
        if let featured = featured { queryItems.append(URLQueryItem(name: "featured", value: String(featured))) }
        if let onSale = onSale { queryItems.append(URLQueryItem(name: "on_sale", value: String(onSale))) }
        
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems) // Auth hinzufügen

        guard let url = urlComponents?.url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print("WooCommerceAPIManager: Fetching products from URL: \(url.absoluteString)")
        
        // Spezielle Behandlung für getProducts, da Paginierungs-Header benötigt werden
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WooCommerceAPIError.networkError(NSError(domain: "WooCommerceAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]))
            }

            if !(200...299).contains(httpResponse.statusCode) {
                var errorMessage: String?
                var errorCode: String?
                if let errorDetails = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                    errorMessage = errorDetails.message
                    errorCode = errorDetails.code
                }
                print("WooCommerceAPIManager: Server error \(httpResponse.statusCode) for getProducts URL \(url.absoluteString). Code: \(errorCode ?? "N/A"), Message: \(errorMessage ?? "N/A")")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage, errorCode: errorCode)
            }
            
            let decoder = JSONDecoder()
            // decoder.keyDecodingStrategy = .convertFromSnakeCase // Falls deine Modelle das erfordern
            let products = try decoder.decode([WooCommerceProduct].self, from: data)
            
            let totalPagesHeader = httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages")
            let totalCountHeader = httpResponse.value(forHTTPHeaderField: "X-WP-Total")
            let totalPages = Int(totalPagesHeader ?? "0") ?? 0
            let totalCount = Int(totalCountHeader ?? "0") ?? 0
            
            return WooCommerceProductsResponseContainer(products: products, totalPages: totalPages, totalCount: totalCount)

        } catch let error as DecodingError {
            print("WooCommerceAPIManager: Decoding error for getProducts URL \(url.absoluteString): \(error)")
            throw WooCommerceAPIError.decodingError(error)
        } catch let error as WooCommerceAPIError {
            throw error
        } catch {
            print("WooCommerceAPIManager: Network or other error for getProducts URL \(url.absoluteString): \(error)")
            throw WooCommerceAPIError.networkError(error)
        }
    }

    func getProductBySlug(productSlug: String) async throws -> WooCommerceProduct? {
        var urlComponents = URLComponents(string: coreApiBaseURL + "products")
        if urlComponents == nil { throw WooCommerceAPIError.invalidURL }

        var queryItems = [URLQueryItem(name: "slug", value: productSlug)]
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems) // Auth hinzufügen

        guard let url = urlComponents?.url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print("WooCommerceAPIManager: Fetching product by slug from URL: \(url.absoluteString)")
        
        let productsArray: [WooCommerceProduct] = try await performRequest(request: request, decodingType: [WooCommerceProduct].self, functionNameForLog: "getProductBySlug")
        return productsArray.first
    }

    func getProductVariations(productId: Int) async throws -> [WooCommerceProductVariation] {
        var urlComponents = URLComponents(string: coreApiBaseURL + "products/\(productId)/variations")
        if urlComponents == nil { throw WooCommerceAPIError.invalidURL }

        var queryItems = [URLQueryItem(name: "per_page", value: "100")] // Annahme: Max 100 Variationen
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems) // Auth hinzufügen

        guard let url = urlComponents?.url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print("WooCommerceAPIManager: Fetching variations for product ID \(productId) from URL: \(url.absoluteString)")
        
        return try await performRequest(request: request, decodingType: [WooCommerceProductVariation].self, functionNameForLog: "getProductVariations")
    }

    // MARK: - Private Generic Request Performer
    private func performRequest<T: Decodable>(request: URLRequest, decodingType: T.Type, functionNameForLog: String) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw WooCommerceAPIError.networkError(NSError(domain: "WooCommerceAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]))
            }

            if !(200...299).contains(httpResponse.statusCode) {
                var errorMessage: String?
                var errorCode: String?
                // Versuche, eine WooCommerceErrorResponse zu dekodieren
                if let errorDetails = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                    errorMessage = errorDetails.message
                    errorCode = errorDetails.code
                }
                print("WooCommerceAPIManager: Server error \(httpResponse.statusCode) for \(functionNameForLog) URL \(request.url?.absoluteString ?? "N/A"). Code: \(errorCode ?? "N/A"), Message: \(errorMessage ?? "N/A")")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage, errorCode: errorCode)
            }
            
            // Spezielle Behandlung für leere Antworten, wenn T optional ist (hier nicht der Fall)
            // oder wenn ein 204 No Content erwartet wird.
            if data.isEmpty && !(decodingType is Optional<Any>.Type) {
                 // Wenn T kein Optional ist und die Daten leer sind, ist das ein Problem,
                 // es sei denn, der Statuscode impliziert "No Content" (z.B. 204).
                 // Für GET-Anfragen, die eine Entität erwarten, sollte data nicht leer sein bei 200 OK.
                 if httpResponse.statusCode == 204 {
                     // Dies sollte nicht passieren, wenn T nicht optional ist und wir Inhalt erwarten
                     print("WooCommerceAPIManager: Warning - Received 204 No Content but expected to decode \(String(describing: T.self)) for \(functionNameForLog).")
                     // Hier könntest du entscheiden, einen Fehler zu werfen oder mit einem "Standardwert" für T umzugehen,
                     // aber da T nicht optional ist, ist ein Fehler wahrscheinlicher.
                     // Für diesen generischen Performer nehmen wir an, dass leere Daten bei nicht-optionalem T ein Fehler sind, wenn nicht 204.
                     // Wenn 204, und T ist nicht optional, ist es ein Widerspruch zur API-Definition.
                 }
                 // throw WooCommerceAPIError.noData // oder spezifischer Fehler
            }


            let decoder = JSONDecoder()
            // Setze hier ggf. Key-Decoding-Strategien, wenn deine JSON-Keys nicht den Swift-Property-Namen entsprechen
            // z.B. decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(T.self, from: data)

        } catch let error as DecodingError {
            print("WooCommerceAPIManager: Decoding error for \(functionNameForLog) URL \(request.url?.absoluteString ?? "N/A"): \(error)")
            throw WooCommerceAPIError.decodingError(error)
        } catch let error as WooCommerceAPIError {
            throw error // Bereits ein WooCommerceAPIError, einfach weiterwerfen
        } catch {
            print("WooCommerceAPIManager: Network or other error for \(functionNameForLog) URL \(request.url?.absoluteString ?? "N/A"): \(error)")
            throw WooCommerceAPIError.networkError(error) // Oder .underlying(error), je nach Präferenz
        }
    }
}
