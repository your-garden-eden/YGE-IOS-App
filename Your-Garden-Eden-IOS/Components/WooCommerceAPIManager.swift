// YGE-IOS-App/Core/Networking/WooCommerceAPIManager.swift

import Foundation

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()

    private let coreApiBaseURL = AppConfig.WooCommerce.coreApiBaseURL
    private let consumerKey = "ck_764caa58c2fd1cc7a0ad705630b3f8f2ea397dad"
    private let consumerSecret = "cs_5ca3357f994013428fb5028baa3bfc8f33e4f969"
    
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public API - Categories

    func fetchCategories(
        parent: Int? = nil,
        hideEmpty: Bool = true
    ) async throws -> [WooCommerceCategory] {
        var queryItems = [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "hide_empty", value: String(hideEmpty)),
            URLQueryItem(name: "orderby", value: "name"),
            URLQueryItem(name: "order", value: "asc")
        ]
        if let parentId = parent {
            queryItems.append(URLQueryItem(name: "parent", value: String(parentId)))
        }

        let (categories, _) = try await performRequest(
            path: "products/categories",
            queryItems: queryItems,
            decodingType: [WooCommerceCategory].self,
            useSnakeCaseDecoding: true // KORREKTUR: Expliziter Bool-Wert
        )
        return categories
    }

    // MARK: - Public API - Products
    
    func fetchProducts(
        categoryId: Int? = nil,
        perPage: Int = 10,
        page: Int = 1,
        searchQuery: String? = nil,
        featured: Bool? = nil,
        onSale: Bool? = nil,
        orderBy: String = "date",
        order: String = "desc",
        include: [Int]? = nil
    ) async throws -> WooCommerceProductsResponseContainer {
        var queryItems: [URLQueryItem] = []
        
        if let includeIds = include, !includeIds.isEmpty {
            queryItems.append(URLQueryItem(name: "include", value: includeIds.map(String.init).joined(separator: ",")))
            queryItems.append(URLQueryItem(name: "per_page", value: String(includeIds.count)))
        } else {
            queryItems.append(URLQueryItem(name: "per_page", value: String(perPage)))
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
            queryItems.append(URLQueryItem(name: "orderby", value: orderBy))
            queryItems.append(URLQueryItem(name: "order", value: order))
            if let catId = categoryId { queryItems.append(URLQueryItem(name: "category", value: String(catId))) }
            if let searchQuery = searchQuery, !searchQuery.isEmpty { queryItems.append(URLQueryItem(name: "search", value: searchQuery)) }
            if let featured = featured { queryItems.append(URLQueryItem(name: "featured", value: String(featured))) }
            if let onSale = onSale { queryItems.append(URLQueryItem(name: "on_sale", value: String(onSale))) }
        }
        
        let (products, httpResponse) = try await performRequest(
            path: "products",
            queryItems: queryItems,
            decodingType: [WooCommerceProduct].self,
            useSnakeCaseDecoding: false // KORREKTUR: Expliziter Bool-Wert
        )
        
        let totalPages = Int(httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages") ?? "1") ?? 1
        let totalCount = Int(httpResponse.value(forHTTPHeaderField: "X-WP-Total") ?? "0") ?? 0
        
        return WooCommerceProductsResponseContainer(products: products, totalPages: totalPages, totalCount: totalCount)
    }

    func fetchProductById(productId: Int) async throws -> WooCommerceProduct? {
        let container = try await fetchProducts(include: [productId])
        return container.products.first
    }
    
    func fetchProductBySlug(productSlug: String) async throws -> WooCommerceProduct? {
        let queryItems = [URLQueryItem(name: "slug", value: productSlug)]
        let (products, _) = try await performRequest(
            path: "products",
            queryItems: queryItems,
            decodingType: [WooCommerceProduct].self,
            useSnakeCaseDecoding: false // KORREKTUR: Expliziter Bool-Wert
        )
        return products.first
    }

    func fetchProductVariations(productId: Int) async throws -> [WooCommerceProductVariation] {
        let queryItems = [URLQueryItem(name: "per_page", value: "100")]
        let (variations, _) = try await performRequest(
            path: "products/\(productId)/variations",
            queryItems: queryItems,
            decodingType: [WooCommerceProductVariation].self,
            useSnakeCaseDecoding: true // KORREKTUR: Expliziter Bool-Wert
        )
        return variations
    }

    // MARK: - Private Core Logic

    private func performRequest<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem],
        decodingType: T.Type,
        useSnakeCaseDecoding: Bool // KORREKTUR: Statt Enum, jetzt ein Bool
    ) async throws -> (T, HTTPURLResponse) {
        
        guard var urlComponents = URLComponents(string: coreApiBaseURL + path) else {
            throw WooCommerceAPIError.invalidURL
        }
        urlComponents.queryItems = addAuthQueryItems(to: queryItems)
        
        guard let url = urlComponents.url else {
            throw WooCommerceAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        var responseData: Data?
        do {
            let (data, response) = try await session.data(for: request)
            responseData = data
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WooCommerceAPIError.networkError(NSError(domain: "WooCommerceAPIManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response type."]))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let (message, code) = parseWooCommerceError(from: data)
                print("🔴 WooCommerceAPIManager (\(path)): Server error \(httpResponse.statusCode). Code: \(code ?? "N/A"), Message: \(message ?? "N/A").")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: message, errorCode: code)
            }
            
            let decoder = JSONDecoder()
            if useSnakeCaseDecoding { // KORREKTUR: Logik für die Strategie
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            }
            
            let decodedObject = try decoder.decode(T.self, from: data)
            
            return (decodedObject, httpResponse)
            
        } catch let error as DecodingError {
            logDecodingErrorDetails(error, for: path, url: url, data: responseData)
            throw WooCommerceAPIError.decodingError(error)
        } catch let error as WooCommerceAPIError {
            throw error
        } catch {
            throw WooCommerceAPIError.networkError(error)
        }
    }

    // MARK: - Helper Functions

    private func addAuthQueryItems(to items: [URLQueryItem]) -> [URLQueryItem] {
        var newItems = items
        newItems.append(URLQueryItem(name: "consumer_key", value: self.consumerKey))
        newItems.append(URLQueryItem(name: "consumer_secret", value: self.consumerSecret))
        return newItems
    }
    
    private func parseWooCommerceError(from data: Data) -> (message: String?, code: String?) {
        if let errorDetails = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
            return (errorDetails.message, errorDetails.code)
        }
        return (nil, nil)
    }

    private func logDecodingErrorDetails(_ error: DecodingError, for functionName: String, url: URL?, data: Data?) {
        var logMessage = "🔴 WooCommerceAPIManager: Detailed decoding error for \(functionName) URL \(url?.absoluteString ?? "N/A"):\n"
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
