// Path: Your-Garden-Eden-IOS/Core/Service/WooCommerceAPIManager.swift

import Foundation

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()

    private let customApiBaseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com/wp-json/your-garden-eden/v1"
    
    // 🚨 ACHTUNG: Keys sind hier nur für die Demonstration. Im echten Projekt in einer .xcconfig-Datei speichern!
    private let consumerKey = "ck_764caa58c2fd1cc7a0ad705630b3f8f2ea397dad"
    private let consumerSecret = "cs_5ca3357f994013428fb5028baa3bfc8f33e4f969"
    
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        print("✅ WooCommerceAPIManager initialized.")
    }

    // MARK: - Public API - Products & Categories (Core v3 API)
    
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
            if let featured = featured { queryItems.append(URLQueryItem(name: "featured", value: String(featured))) }
            if let onSale = onSale { queryItems.append(URLQueryItem(name: "on_sale", value: String(onSale))) }
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
            URLQueryItem(name: "orderby", value: "menu_order"),
            URLQueryItem(name: "order", value: "asc")
        ]
        if let parentId = parent { queryItems.append(URLQueryItem(name: "parent", value: String(parentId))) }
        let (categories, _) = try await performCoreRequest(path: "products/categories", queryItems: queryItems, decodingType: [WooCommerceCategory].self)
        return categories
    }

    // MARK: - Public API - Wishlist (Custom API)

    struct WishlistResponse: Decodable { let items: [WishlistItem] }
    struct WishlistItem: Decodable, Hashable {
        let productId: Int
        enum CodingKeys: String, CodingKey { case productId = "product_id" }
    }
    struct EmptyResponse: Decodable {}

    func fetchUserWishlist() async throws -> WishlistResponse {
        return try await performCustomAPIRequest(path: "/wishlist", method: "GET")
    }
    
    func addToUserWishlist(productId: Int, variationId: Int?) async throws {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        let _: EmptyResponse = try await performCustomAPIRequest(path: "/wishlist/item/add", method: "POST", body: body)
    }
    
    func removeFromUserWishlist(productId: Int, variationId: Int?) async throws {
        let body: [String: Any?] = ["product_id": productId, "variation_id": variationId]
        let _: EmptyResponse = try await performCustomAPIRequest(path: "/wishlist/item/remove", method: "POST", body: body)
    }

    // MARK: - Private Core Request Logic
    
    private func performCoreRequest<T: Decodable>(path: String, queryItems: [URLQueryItem], decodingType: T.Type) async throws -> (T, HTTPURLResponse) {
        guard var urlComponents = URLComponents(string: AppConfig.WooCommerce.coreApiBaseURL + path) else { throw WooCommerceAPIError.invalidURL }
        urlComponents.queryItems = addAuthQueryItems(to: queryItems)
        return try await performRequest(url: urlComponents.url, httpMethod: "GET", decodingType: decodingType)
    }

    private func performCustomAPIRequest<T: Decodable>(path: String, method: String, body: [String: Any?]? = nil) async throws -> T {
        guard let url = URL(string: customApiBaseURL + path) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        guard let token = await AuthManager.shared.getAuthToken() else { throw WooCommerceAPIError.notAuthenticated }
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
            guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0, userInfo: nil)) }

            guard (200...299).contains(httpResponse.statusCode) else {
                let (message, code) = parseWooCommerceError(from: data)
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: message, errorCode: code)
            }
            
            if T.self == EmptyResponse.self { return (EmptyResponse() as! T, httpResponse) }

            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(T.self, from: data)
            return (decodedObject, httpResponse)
            
        } catch let error as DecodingError {
            logDecodingErrorDetails(error, for: request.url?.path() ?? "N/A", data: request.httpBody)
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

    // MARK: - Helper Functions
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
        return (String(data: data, encoding: .utf8) ?? "Unknown Error", nil)
    }

    private func logDecodingErrorDetails(_ error: DecodingError, for functionName: String, data: Data?) {
        var logMessage = "🔴 WooCommerceAPIManager: Detailed decoding error for \(functionName):\n"
        if let data = data, let rawString = String(data: data, encoding: .utf8) { logMessage += "Raw Data: \(rawString.prefix(1000))\n" }
        logMessage += "\(error)"
        print(logMessage)
    }
}
