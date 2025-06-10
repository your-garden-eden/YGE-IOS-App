// YGE-IOS-App/Core/Networking/WooCommerceAPIManager.swift

import Foundation

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()

    private let coreApiBaseURL = AppConfig.WooCommerce.coreApiBaseURL
    private let session: URLSession

    private let consumerKey = "ck_764caa58c2fd1cc7a0ad705630b3f8f2ea397dad"
    private let consumerSecret = "cs_5ca3357f994013428fb5028baa3bfc8f33e4f969"

    private init() {
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
        order: String = "desc",
        include: [Int]? = nil // Parameter für spezifische Produkt-IDs
    ) async throws -> WooCommerceProductsResponseContainer {
        var urlComponents = URLComponents(string: coreApiBaseURL + "products")
        if urlComponents == nil { throw WooCommerceAPIError.invalidURL }

        var queryItems: [URLQueryItem] = []
        
        // 'include' hat Vorrang vor anderen Filtern, wenn es verwendet wird.
        // Wenn 'include' gesetzt ist, sind 'page', 'category', 'search' etc. oft nicht nötig oder werden ignoriert.
        // 'per_page' sollte bei 'include' der Anzahl der IDs entsprechen, um sicher alle zu bekommen.
        if let includeIds = include, !includeIds.isEmpty {
            queryItems.append(URLQueryItem(name: "include", value: includeIds.map(String.init).joined(separator: ",")))
            // Wenn 'include' verwendet wird, setzen wir perPage auf die Anzahl der IDs,
            // um sicherzustellen, dass alle angeforderten Produkte zurückgegeben werden,
            // falls die API Paginierung auf 'include'-Anfragen anwendet.
            queryItems.append(URLQueryItem(name: "per_page", value: String(includeIds.count)))
            // Parameter wie 'page', 'orderby', 'order' sind bei 'include' oft weniger relevant oder werden ignoriert.
            // Du kannst sie hinzufügen, wenn deine API sie in Kombination mit 'include' unterstützt.
            // queryItems.append(URLQueryItem(name: "orderby", value: orderBy)) // Z.B. um nach 'include' Reihenfolge zu sortieren
            // queryItems.append(URLQueryItem(name: "order", value: order))
        } else {
            // Standard-Parameter, wenn 'include' nicht verwendet wird
            queryItems.append(URLQueryItem(name: "per_page", value: String(perPage)))
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
            queryItems.append(URLQueryItem(name: "orderby", value: orderBy))
            queryItems.append(URLQueryItem(name: "order", value: order))
            if let catId = categoryId { queryItems.append(URLQueryItem(name: "category", value: String(catId))) }
            if let searchQuery = searchQuery, !searchQuery.isEmpty { queryItems.append(URLQueryItem(name: "search", value: searchQuery)) }
            if let featured = featured { queryItems.append(URLQueryItem(name: "featured", value: String(featured))) }
            if let onSale = onSale { queryItems.append(URLQueryItem(name: "on_sale", value: String(onSale))) }
        }
        
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
                    errorMessage = errorDetails.message; errorCode = errorDetails.code
                    print("WooCommerceAPIManager (\(#function)): Server error \(httpResponse.statusCode) for URL \(url.absoluteString). Code: \(errorCode ?? "N/A"), Message: \(errorMessage ?? "N/A"). Raw Data: \(String(data: data, encoding: .utf8)?.prefix(500) ?? "No raw data")")
                } else {
                     print("WooCommerceAPIManager (\(#function)): Server error \(httpResponse.statusCode) for URL \(url.absoluteString). Could not parse error JSON. Raw Data: \(String(data: data, encoding: .utf8)?.prefix(500) ?? "No raw data")")
                }
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage, errorCode: errorCode)
            }
            
            let decoder = JSONDecoder()
            let products = try decoder.decode([WooCommerceProduct].self, from: data)
            
            let totalPagesHeader = httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages")
            let totalCountHeader = httpResponse.value(forHTTPHeaderField: "X-WP-Total")
            
            // Wenn 'include' verwendet wird, sind die Paginierungs-Header möglicherweise nicht relevant
            // oder die API liefert sie nicht. Fallback auf die Anzahl der zurückgegebenen Produkte.
            let totalPages = Int(totalPagesHeader ?? "") ?? (include != nil ? 1 : (products.isEmpty ? 0 : 1))
            let totalCount = Int(totalCountHeader ?? "") ?? products.count
            
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

    /// Ruft ein einzelnes Produkt anhand seiner ID ab.
    func getProductById(productId: Int) async throws -> WooCommerceProduct? {
        // Verwende die getProducts-Methode mit 'include'. 'perPage' wird innerhalb von getProducts
        // bei Verwendung von 'include' auf die Anzahl der IDs gesetzt.
        let container = try await getProducts(include: [productId])
        return container.products.first
    }
    
    /// Ruft ein einzelnes Produkt anhand seines Slugs ab.
    func getProductBySlug(productSlug: String) async throws -> WooCommerceProduct? {
        var urlComponents = URLComponents(string: coreApiBaseURL + "products")
        if urlComponents == nil { throw WooCommerceAPIError.invalidURL }

        let queryItems = [URLQueryItem(name: "slug", value: productSlug)]
        urlComponents?.queryItems = addAuthQueryItems(to: queryItems)

        guard let url = urlComponents?.url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
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
        
        return try await performRequest(request: request, decodingType: [WooCommerceProductVariation].self, functionNameForLog: #function)
    }

    // MARK: - Private Generic Request Performer
    private func performRequest<T: Decodable>(request: URLRequest, decodingType: T.Type, functionNameForLog: String) async throws -> T {
        var responseData: Data?
        do {
            print("WooCommerceAPIManager (\(functionNameForLog)): Performing request to \(request.url?.absoluteString ?? "N/A")")
            let (data, response) = try await session.data(for: request)
            responseData = data
            guard let httpResponse = response as? HTTPURLResponse else {
                print("WooCommerceAPIManager (\(functionNameForLog)): Invalid HTTP response type.")
                throw WooCommerceAPIError.networkError(NSError(domain: "WooCommerceAPIManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response type."]))
            }
            print("WooCommerceAPIManager (\(functionNameForLog)): Received status code \(httpResponse.statusCode).")
            if !(200...299).contains(httpResponse.statusCode) {
                var errorMessage: String?; var errorCode: String?
                if let errorDetails = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                    errorMessage = errorDetails.message; errorCode = errorDetails.code
                    print("WooCommerceAPIManager (\(functionNameForLog)): Server error \(httpResponse.statusCode). Code: \(errorCode ?? "N/A"), Message: \(errorMessage ?? "N/A"). Raw: \(String(data:data, encoding: .utf8)?.prefix(500) ?? "")")
                } else {
                    print("WooCommerceAPIManager (\(functionNameForLog)): Server error \(httpResponse.statusCode). No parsable JSON. Raw: \(String(data:data, encoding: .utf8)?.prefix(500) ?? "")")
                }
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage, errorCode: errorCode)
            }
            if httpResponse.statusCode == 204 {
                if T.self == Void.self { return () as! T }
                else if data.isEmpty { throw WooCommerceAPIError.noData }
            }
            if data.isEmpty && T.self != Void.self { throw WooCommerceAPIError.noData }
            let decoder = JSONDecoder()
            let isProductType = T.self is WooCommerceProduct.Type || T.self is Array<WooCommerceProduct>.Type
            if !isProductType { decoder.keyDecodingStrategy = .convertFromSnakeCase }
            else { print("WooCommerceAPIManager (\(functionNameForLog)): NOT using .convertFromSnakeCase for WooCommerceProduct type.")}
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            print("WooCommerceAPIManager (\(functionNameForLog)): Decoding error.")
            logDecodingErrorDetails(error, for: functionNameForLog, url: request.url, data: responseData)
            throw WooCommerceAPIError.decodingError(error)
        } catch let error as WooCommerceAPIError { throw error }
        catch { throw WooCommerceAPIError.networkError(error) }
    }

    // MARK: - Error Logging Helper
    private func logDecodingErrorDetails(_ error: DecodingError, for functionName: String, url: URL?, data: Data?) {
        // ... (deine bestehende Implementierung von logDecodingErrorDetails)
        var logMessage = "WooCommerceAPIManager: Detailed decoding error for \(functionName) URL \(url?.absoluteString ?? "N/A"):\n"
        if let data = data, !data.isEmpty, let rawString = String(data: data, encoding: .utf8) { logMessage += "Raw Data (first 1000 chars): \(rawString.prefix(1000))\n"
        } else if let data = data, data.isEmpty { logMessage += "Raw Data: Received empty data.\n"
        } else { logMessage += "Raw Data: Not available (nil or not UTF-8).\n" }
        switch error {
        case .typeMismatch(let type, let context): logMessage += "  Type mismatch: '\(type)' in path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Debug: \(context.debugDescription)"
        case .valueNotFound(let type, let context): logMessage += "  Value not found: '\(type)' in path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Debug: \(context.debugDescription)"
        case .keyNotFound(let key, let context): logMessage += "  Key not found: '\(key.stringValue)' in path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Debug: \(context.debugDescription)"
        case .dataCorrupted(let context): logMessage += "  Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")). Debug: \(context.debugDescription)"
        @unknown default: logMessage += "  Unknown decoding error: \(error.localizedDescription)"
        }
        print(logMessage)
    }
}
