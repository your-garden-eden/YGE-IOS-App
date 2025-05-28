// YGE-IOS-App/Core/Managers/WooCommerceAPIManager.swift

import Foundation

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()

    private let coreApiBaseURL = AppConfig.WooCommerce.coreApiBaseURL
    private let session: URLSession

    private let consumerKey = "ck_764caa58c2fd1cc7a0ad705630b3f8f2ea397dad"
    private let consumerSecret = "cs_5ca3357f994013428fb5028baa3bfc8f33e4f969"

    init() {
        print("WooCommerceAPIManager initialized (REAL API MODE)")
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }

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
        orderby: String = "name",
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
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems)

        guard let url = urlComponents?.url else {
            throw WooCommerceAPIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return try await performRequest(request: request, decodingType: [WooCommerceCategory].self, functionNameForLog: #function)
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
        
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems)

        guard let url = urlComponents?.url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        var responseData: Data?
        
        do {
            let (data, response) = try await session.data(for: request)
            responseData = data
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("WooCommerceAPIManager (\(#function)): Invalid HTTP response for URL \(url.absoluteString)")
                throw WooCommerceAPIError.networkError(NSError(domain: "WooCommerceAPIManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response type, not HTTPURLResponse."]))
            }

            if !(200...299).contains(httpResponse.statusCode) {
                var errorMessage: String?
                var errorCode: String?
                if let errorDetails = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                    errorMessage = errorDetails.message
                    errorCode = errorDetails.code
                }
                print("WooCommerceAPIManager (\(#function)): Server error \(httpResponse.statusCode) for URL \(url.absoluteString). Code: \(errorCode ?? "N/A"), Message: \(errorMessage ?? "N/A")")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage, errorCode: errorCode)
            }
            
            let decoder = JSONDecoder()
            // WooCommerceProduct hat eine manuelle Codable-Implementierung,
            // daher sollte die keyDecodingStrategy hier nicht angewendet werden.
            // // decoder.keyDecodingStrategy = .convertFromSnakeCase // AUSKOMMENTIERT für Produkte

            // Falls deine dateCreated etc. im WooCommerceProduct-Modell als Date-Objekte
            // deklariert wären (aktuell sind sie Strings), müsstest du hier
            // eine dateDecodingStrategy konfigurieren.
            // let dateFormatter = DateFormatter()
            // dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            // dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            // dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            // decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let products = try decoder.decode([WooCommerceProduct].self, from: data)
            
            let totalPagesHeader = httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages")
            let totalCountHeader = httpResponse.value(forHTTPHeaderField: "X-WP-Total")
            let totalPages = Int(totalPagesHeader ?? "") ?? 0
            let totalCount = Int(totalCountHeader ?? "") ?? 0
            
            return WooCommerceProductsResponseContainer(products: products, totalPages: totalPages, totalCount: totalCount)

        } catch let error as DecodingError {
            print("WooCommerceAPIManager (\(#function)): Decoding error for URL \(url.absoluteString).")
            logDecodingErrorDetails(error, for: #function, url: url, data: responseData)
            throw WooCommerceAPIError.decodingError(error)
        } catch let error as WooCommerceAPIError {
            throw error
        } catch {
            print("WooCommerceAPIManager (\(#function)): Network or other error for URL \(url.absoluteString): \(error)")
            throw WooCommerceAPIError.networkError(error)
        }
    }

    func getProductBySlug(productSlug: String) async throws -> WooCommerceProduct? {
        var urlComponents = URLComponents(string: coreApiBaseURL + "products")
        if urlComponents == nil { throw WooCommerceAPIError.invalidURL }

        let queryItems = [URLQueryItem(name: "slug", value: productSlug)]
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems)

        guard let url = urlComponents?.url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Da WooCommerceProduct manuell Codable implementiert, wird performRequest so angepasst,
        // dass es die keyDecodingStrategy für diesen Typ nicht anwendet.
        let productsArray: [WooCommerceProduct] = try await performRequest(request: request, decodingType: [WooCommerceProduct].self, functionNameForLog: #function)
        return productsArray.first
    }

    func getProductVariations(productId: Int, perPage: Int = 100) async throws -> [WooCommerceProductVariation] {
        var urlComponents = URLComponents(string: coreApiBaseURL + "products/\(productId)/variations")
        if urlComponents == nil { throw WooCommerceAPIError.invalidURL }

        let queryItems = [URLQueryItem(name: "per_page", value: String(perPage))]
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems)

        guard let url = urlComponents?.url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Annahme: WooCommerceProductVariation verwendet KEINE manuelle Codable Implementierung
        // und profitiert von .convertFromSnakeCase. Falls doch, müsste performRequest erweitert werden.
        return try await performRequest(request: request, decodingType: [WooCommerceProductVariation].self, functionNameForLog: #function)
    }

    // MARK: - Private Generic Request Performer
    private func performRequest<T: Decodable>(request: URLRequest, decodingType: T.Type, functionNameForLog: String) async throws -> T {
        var responseData: Data?

        do {
            let (data, response) = try await session.data(for: request)
            responseData = data

            guard let httpResponse = response as? HTTPURLResponse else {
                print("WooCommerceAPIManager (\(functionNameForLog)): Invalid HTTP response for URL \(request.url?.absoluteString ?? "N/A")")
                throw WooCommerceAPIError.networkError(NSError(domain: "WooCommerceAPIManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response type, not HTTPURLResponse."]))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                var errorMessage: String?
                var errorCode: String?
                if let errorDetails = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                    errorMessage = errorDetails.message
                    errorCode = errorDetails.code
                }
                print("WooCommerceAPIManager (\(functionNameForLog)): Server error \(httpResponse.statusCode) for URL \(request.url?.absoluteString ?? "N/A"). Code: \(errorCode ?? "N/A"), Message: \(errorMessage ?? "N/A")")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage, errorCode: errorCode)
            }
            
            if httpResponse.statusCode == 204 { // No Content
                if T.self == Void.self { return () as! T }
                else if data.isEmpty { throw WooCommerceAPIError.noData }
            }
            
            if data.isEmpty && T.self != Void.self { throw WooCommerceAPIError.noData }

            let decoder = JSONDecoder()
            
            // *** WICHTIGE ÄNDERUNG FÜR TYP-SPEZIFISCHE DEKODIERUNGSSTRATEGIE ***
            // Überprüfe, ob T WooCommerceProduct oder ein Array davon ist.
            // Wenn ja, verwende KEINE keyDecodingStrategy, da WooCommerceProduct Codable manuell implementiert.
            // Für andere Typen (z.B. WooCommerceCategory, WooCommerceProductVariation), verwende .convertFromSnakeCase.
            let isProductType = T.self is WooCommerceProduct.Type || T.self is Array<WooCommerceProduct>.Type
            
            if !isProductType {
                 print("WooCommerceAPIManager (\(functionNameForLog)): Using .convertFromSnakeCase for type \(String(describing: T.self))")
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            } else {
                 print("WooCommerceAPIManager (\(functionNameForLog)): NOT using .convertFromSnakeCase for WooCommerceProduct type (\(String(describing: T.self))). Relying on manual Codable implementation.")
            }
            
            // Datumsformatierung: Falls deine Modelle Date-Objekte statt Strings für Daten verwenden.
            // Dies müsste auch typspezifisch gehandhabt werden, wenn verschiedene Modelle
            // unterschiedliche Datumsformate oder String/Date-Typen verwenden.
            // Für WooCommerceProduct sind Daten aktuell Strings, daher ist keine Date-Strategie nötig.
            // Beispiel:
            // if T.self is WooCommerceProductVariation.Type { // Angenommen Variation hätte Date-Objekte
            //    let dateFormatter = DateFormatter()
            //    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            //    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            //    decoder.dateDecodingStrategy = .formatted(dateFormatter)
            // }
            
            return try decoder.decode(T.self, from: data)

        } catch let error as DecodingError {
            print("WooCommerceAPIManager (\(functionNameForLog)): Decoding error for URL \(request.url?.absoluteString ?? "N/A").")
            logDecodingErrorDetails(error, for: functionNameForLog, url: request.url, data: responseData)
            throw WooCommerceAPIError.decodingError(error)
        } catch let error as WooCommerceAPIError {
            throw error
        } catch {
            print("WooCommerceAPIManager (\(functionNameForLog)): Network or other error for URL \(request.url?.absoluteString ?? "N/A"): \(error)")
            throw WooCommerceAPIError.networkError(error)
        }
    }

    private func logDecodingErrorDetails(_ error: DecodingError, for functionName: String, url: URL?, data: Data?) {
        var logMessage = "WooCommerceAPIManager: Detailed decoding error for \(functionName) URL \(url?.absoluteString ?? "N/A"):\n"
        
        if let data = data, !data.isEmpty, let rawString = String(data: data, encoding: .utf8) {
            logMessage += "Raw Data (first 1000 chars): \(rawString.prefix(1000))\n"
        } else if let data = data, data.isEmpty {
            logMessage += "Raw Data: Received empty data.\n"
        } else {
            logMessage += "Raw Data: Not available in this context, data was nil, or not UTF-8.\n"
        }

        switch error {
        case .typeMismatch(let type, let context):
            logMessage += "  Type mismatch: Expected type '\(type)' not found.\n"
            logMessage += "  Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))\n"
            logMessage += "  Debug Description: \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            logMessage += "  Value not found: No value found for expected type '\(type)'.\n"
            logMessage += "  Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))\n"
            logMessage += "  Debug Description: \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            logMessage += "  Key not found: Key '\(key.stringValue)' not found.\n"
            logMessage += "  Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))\n"
            logMessage += "  Debug Description: \(context.debugDescription)"
        case .dataCorrupted(let context):
            logMessage += "  Data corrupted: The data found is not valid.\n"
            logMessage += "  Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))\n"
            logMessage += "  Debug Description: \(context.debugDescription)"
        @unknown default:
            logMessage += "  Unknown decoding error: \(error.localizedDescription)"
        }
        print(logMessage)
    }
}
