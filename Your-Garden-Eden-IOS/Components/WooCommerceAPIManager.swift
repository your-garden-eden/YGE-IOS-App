// YGE-IOS-App/Core/Networking/WooCommerceAPIManager.swift

import Foundation

// MARK: - Datenmodelle für die Wishlist API
struct WishlistResponse: Decodable {
    let items: [WishlistItem]
}

struct WishlistItem: Decodable, Hashable {
    let productId: Int
    let variationId: Int?
    let addedAt: String
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case variationId = "variation_id"
        case addedAt = "added_at"
    }
}

// Eine leere Decodable-Struktur für Anfragen, bei denen wir keine Daten zurückerwarten.
struct EmptyResponse: Decodable {}


// MARK: - WooCommerceAPIManager

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()

    private let coreApiBaseURL = AppConfig.WooCommerce.coreApiBaseURL
    // NEU: Die Basis-URL für unsere eigenen Endpunkte aus der functions.php
    private let customApiBaseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com/wp-json/your-garden-eden/v1"
    
    private let consumerKey = "ck_764caa58c2fd1cc7a0ad705630b3f8f2ea397dad"
    private let consumerSecret = "cs_5ca3357f994013428fb5028baa3bfc8f33e4f969"
    
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public API - Categories (unverändert)
    func fetchCategories(parent: Int? = nil, hideEmpty: Bool = true) async throws -> [WooCommerceCategory] {
        var queryItems = [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "hide_empty", value: String(hideEmpty)),
            URLQueryItem(name: "orderby", value: "name"),
            URLQueryItem(name: "order", value: "asc")
        ]
        if let parentId = parent { queryItems.append(URLQueryItem(name: "parent", value: String(parentId))) }
        let (categories, _) = try await performRequest(path: "products/categories", queryItems: queryItems, decodingType: [WooCommerceCategory].self, useSnakeCaseDecoding: true)
        return categories
    }

    // MARK: - Public API - Products (unverändert)
    func fetchProducts(categoryId: Int? = nil, perPage: Int = 10, page: Int = 1, searchQuery: String? = nil, featured: Bool? = nil, onSale: Bool? = nil, orderBy: String = "date", order: String = "desc", include: [Int]? = nil) async throws -> WooCommerceProductsResponseContainer {
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
        let (products, httpResponse) = try await performRequest(path: "products", queryItems: queryItems, decodingType: [WooCommerceProduct].self, useSnakeCaseDecoding: false)
        let totalPages = Int(httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages") ?? "1") ?? 1
        let totalCount = Int(httpResponse.value(forHTTPHeaderField: "X-WP-Total") ?? "0") ?? 0
        return WooCommerceProductsResponseContainer(products: products, totalPages: totalPages, totalCount: totalCount)
    }

    func fetchProductById(productId: Int) async throws -> WooCommerceProduct? {
        return try await fetchProducts(include: [productId]).products.first
    }
    
    func fetchProductBySlug(productSlug: String) async throws -> WooCommerceProduct? {
        let queryItems = [URLQueryItem(name: "slug", value: productSlug)]
        let (products, _) = try await performRequest(path: "products", queryItems: queryItems, decodingType: [WooCommerceProduct].self, useSnakeCaseDecoding: false)
        return products.first
    }

    func fetchProductVariations(productId: Int) async throws -> [WooCommerceProductVariation] {
        let queryItems = [URLQueryItem(name: "per_page", value: "100")]
        let (variations, _) = try await performRequest(path: "products/\(productId)/variations", queryItems: queryItems, decodingType: [WooCommerceProductVariation].self, useSnakeCaseDecoding: true)
        return variations
    }

    // MARK: - NEU: Public API - Wishlist
    
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

    // MARK: - Private Core Logic (unverändert)
    private func performRequest<T: Decodable>(path: String, queryItems: [URLQueryItem], decodingType: T.Type, useSnakeCaseDecoding: Bool) async throws -> (T, HTTPURLResponse) {
        guard var urlComponents = URLComponents(string: coreApiBaseURL + path) else { throw WooCommerceAPIError.invalidURL }
        urlComponents.queryItems = addAuthQueryItems(to: queryItems)
        guard let url = urlComponents.url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.networkError(NSError(domain: "WooCommerceAPIManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response type."])) }
            guard (200...299).contains(httpResponse.statusCode) else {
                let (message, code) = parseWooCommerceError(from: data)
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: message, errorCode: code)
            }
            let decoder = JSONDecoder()
            if useSnakeCaseDecoding { decoder.keyDecodingStrategy = .convertFromSnakeCase }
            let decodedObject = try decoder.decode(T.self, from: data)
            return (decodedObject, httpResponse)
        } catch let error as DecodingError {
            logDecodingErrorDetails(error, for: path, url: url, data: nil)
            throw WooCommerceAPIError.decodingError(error)
        } catch { throw WooCommerceAPIError.underlying(error) }
    }

    // MARK: - NEU: Private Core Logic für Custom Endpoints
    private func performCustomAPIRequest<T: Decodable>(path: String, method: String, body: [String: Any?]? = nil) async throws -> T {
        guard let url = URL(string: customApiBaseURL + path) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = AuthManager.shared.getAuthToken() else { throw WooCommerceAPIError.notAuthenticated }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            let nonNilBody = body.compactMapValues { $0 }
            request.httpBody = try? JSONSerialization.data(withJSONObject: nonNilBody)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let (message, code) = parseWooCommerceError(from: data)
            throw WooCommerceAPIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: message, errorCode: code)
        }
        
        if T.self == EmptyResponse.self { return EmptyResponse() as! T }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logDecodingErrorDetails(error as! DecodingError, for: path, url: url, data: data)
            throw WooCommerceAPIError.decodingError(error)
        }
    }

    // MARK: - Helper Functions (unverändert)
    private func addAuthQueryItems(to items: [URLQueryItem]) -> [URLQueryItem] {
        var newItems = items
        newItems.append(URLQueryItem(name: "consumer_key", value: self.consumerKey))
        newItems.append(URLQueryItem(name: "consumer_secret", value: self.consumerSecret))
        return newItems
    }
    
    private func parseWooCommerceError(from data: Data) -> (message: String?, code: String?) {
        return (try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)).map { ($0.message, $0.code) } ?? (nil, nil)
    }

    private func logDecodingErrorDetails(_ error: DecodingError, for functionName: String, url: URL?, data: Data?) {
        var logMessage = "🔴 WooCommerceAPIManager: Detailed decoding error for \(functionName) URL \(url?.absoluteString ?? "N/A"):\n"
        if let data = data, let rawString = String(data: data, encoding: .utf8) { logMessage += "Raw Data: \(rawString.prefix(1000))\n" }
        logMessage += "\(error)"
        print(logMessage)
    }
}
