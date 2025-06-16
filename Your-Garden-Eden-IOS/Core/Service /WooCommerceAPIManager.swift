import Foundation

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()
    
    private let consumerKey = "ck_764caa58c2fd1cc7a0ad705630b3f8f2ea397dad"
    private let consumerSecret = "cs_5ca3357f994013428fb5028baa3bfc8f33e4f969"
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        print("✅ WooCommerceAPIManager initialized.")
    }
    
    // --- Produkte & Kategorien (Core API) ---

    func fetchProducts(categoryId: Int? = nil, perPage: Int = 20, page: Int = 1, searchQuery: String? = nil, featured: Bool? = nil, onSale: Bool? = nil, orderBy: String = "date", order: String = "desc", include: [Int]? = nil) async throws -> WooCommerceProductsResponseContainer {
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
            if let search = searchQuery, !search.isEmpty { queryItems.append(URLQueryItem(name: "search", value: search)) }
            if let feat = featured { queryItems.append(URLQueryItem(name: "featured", value: String(feat))) }
            if let sale = onSale { queryItems.append(URLQueryItem(name: "on_sale", value: String(sale))) }
        }
        let (products, httpResponse) = try await performCoreRequest(path: "products", queryItems: queryItems, decodingType: [WooCommerceProduct].self)
        let totalPages = Int(httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages") ?? "1") ?? 1
        let totalCount = Int(httpResponse.value(forHTTPHeaderField: "X-WP-Total") ?? "0") ?? 0
        return WooCommerceProductsResponseContainer(products: products, totalPages: totalPages, totalCount: totalCount)
    }
    
    func fetchProductVariations(productId: Int) async throws -> [WooCommerceProductVariation] {
        let queryItems = [URLQueryItem(name: "per_page", value: "100")]
        let (variations, _) = try await performCoreRequest(path: "products/\(productId)/variations", queryItems: queryItems, decodingType: [WooCommerceProductVariation].self)
        return variations
    }
    
    func fetchCategories(parent: Int? = nil) async throws -> [WooCommerceCategory] {
        var queryItems = [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "hide_empty", value: "true"),
            URLQueryItem(name: "orderby", value: "name"),
            URLQueryItem(name: "order", value: "asc")
        ]
        if let parentId = parent {
            queryItems.append(URLQueryItem(name: "parent", value: String(parentId)))
        }
        let (categories, _) = try await performCoreRequest(path: "products/categories", queryItems: queryItems, decodingType: [WooCommerceCategory].self)
        return categories
    }

    func fetchCategory(bySlug slug: String) async throws -> WooCommerceCategory? {
        let queryItems = [URLQueryItem(name: "slug", value: slug)]
        let (categories, _) = try await performCoreRequest(path: "products/categories", queryItems: queryItems, decodingType: [WooCommerceCategory].self)
        return categories.first
    }
    
    // --- Wunschliste (YGE Custom API) ---
    
    @MainActor
    func fetchUserWishlist() async throws -> YGEWishlist {
        return try await performCustomAPIRequest(endpoint: AppConfig.YGE.wishlistEndpoint, method: "GET", decodingType: YGEWishlist.self)
    }

    @MainActor
    func addToUserWishlist(productId: Int, variationId: Int?) async throws -> YGEWishlist {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        return try await performCustomAPIRequest(endpoint: AppConfig.YGE.wishlistAddItemEndpoint, method: "POST", body: body, decodingType: YGEWishlist.self)
    }

    @MainActor
    func removeFromUserWishlist(productId: Int, variationId: Int?) async throws -> YGEWishlist {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        return try await performCustomAPIRequest(endpoint: AppConfig.YGE.wishlistRemoveItemEndpoint, method: "POST", body: body, decodingType: YGEWishlist.self)
    }
    
    // MARK: - Private Request Helpers
    
    private func performCoreRequest<T: Decodable>(path: String, queryItems: [URLQueryItem], decodingType: T.Type) async throws -> (T, HTTPURLResponse) {
        guard var urlComponents = URLComponents(string: AppConfig.WooCommerce.coreApiBaseURL + path) else {
            throw WooCommerceAPIError.invalidURL
        }
        urlComponents.queryItems = addAuthQueryItems(to: queryItems)
        return try await performRequest(url: urlComponents.url, httpMethod: "GET", decodingType: decodingType)
    }
    
    @MainActor
    private func performCustomAPIRequest<T: Decodable>(endpoint: String, method: String, body: [String: Any?]? = nil, decodingType: T.Type) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw WooCommerceAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        guard let token = AuthManager.shared.getAuthToken() else {
            throw WooCommerceAPIError.notAuthenticated
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        }
        
        let (decodedObject, _) = try await performRequest(request: request, decodingType: T.self)
        return decodedObject
    }
    
    private func performRequest<T: Decodable>(request: URLRequest, decodingType: T.Type) async throws -> (T, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."]))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let (message, code) = parseWooCommerceError(from: data)
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: message, errorCode: code)
            }
            
            if data.isEmpty, let empty = EmptyResponse() as? T {
                return (empty, httpResponse)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return (try decoder.decode(T.self, from: data), httpResponse)
            
        } catch let error as DecodingError {
            logDecodingErrorDetails(error, for: request.url?.absoluteString ?? "N/A", data: request.httpBody)
            throw WooCommerceAPIError.decodingError(error)
        } catch {
            throw WooCommerceAPIError.underlying(error)
        }
    }
    
    private func performRequest<T: Decodable>(url: URL?, httpMethod: String, decodingType: T.Type) async throws -> (T, HTTPURLResponse) {
        guard let url = url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return try await performRequest(request: request, decodingType: decodingType)
    }
    
    private func addAuthQueryItems(to items: [URLQueryItem]) -> [URLQueryItem] {
        var newItems = items
        newItems.append(URLQueryItem(name: "consumer_key", value: self.consumerKey))
        newItems.append(URLQueryItem(name: "consumer_secret", value: self.consumerSecret))
        return newItems
    }
    
    private func parseWooCommerceError(from data: Data) -> (message: String?, code: String?) {
        if let error = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
            return (error.message, error.code)
        }
        return (String(data: data, encoding: .utf8), nil)
    }
    
    private func logDecodingErrorDetails(_ error: DecodingError, for urlString: String, data: Data?) {
        var logMessage = "🔴 DECODING ERROR for URL: \(urlString)\n"
        if let data = data, let rawString = String(data: data, encoding: .utf8) {
            logMessage += "Request Body: \(rawString.prefix(1000))\n"
        }
        logMessage += "Error Details: \(error)"
        print(logMessage)
    }
}

struct EmptyResponse: Decodable {}
