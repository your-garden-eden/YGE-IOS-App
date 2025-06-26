
// DATEI: WooCommerceAPIManager.swift
// PFAD: Core/Services/WooCommerceAPIManager.swift
// VERSION: 3.2 (FINAL, ENDGÜLTIG KORRIGIERT)
// STATUS: Alle Kompilierungsfehler eliminiert. Operation abgeschlossen.

import Foundation

@MainActor
public class WooCommerceAPIManager {
    public static let shared = WooCommerceAPIManager()
    
    private let authManager: AuthManager
    private let session: URLSession
    private let logger = LogSentinel.shared

    private init() {
        self.authManager = AuthManager.shared
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Core Public Methods
    
    public func fetchProducts(params: ProductFilterParameters, page: Int = 1, perPage: Int = 20) async throws -> WooCommerceProductsResponseContainer {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        if let orderBy = params.orderBy, let order = params.order { queryItems.append(contentsOf: [URLQueryItem(name: "orderby", value: orderBy), URLQueryItem(name: "order", value: order)]) }
        if let catId = params.categoryId { queryItems.append(URLQueryItem(name: "category", value: String(catId))) }
        if let onSale = params.onSale { queryItems.append(URLQueryItem(name: "on_sale", value: String(onSale))) }
        if let featured = params.featured { queryItems.append(URLQueryItem(name: "featured", value: String(featured))) }
        if let search = params.searchQuery, !search.isEmpty { queryItems.append(URLQueryItem(name: "search", value: search)) }
        if let includeIds = params.include, !includeIds.isEmpty { queryItems.append(URLQueryItem(name: "include", value: includeIds.map(String.init).joined(separator: ","))) }
        if let stock = params.stockStatus { queryItems.append(URLQueryItem(name: "stock_status", value: stock.rawValue)) }
        
        let (products, httpResponse): ([WooCommerceProduct], HTTPURLResponse) = try await performRequestAndGetResponse(path: "products", queryItems: queryItems)
        
        let totalPages = Int(httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages") ?? "1") ?? 1
        
        return WooCommerceProductsResponseContainer(products: products, totalPages: totalPages)
    }
    
    public func fetchProductVariations(productId: Int) async throws -> [WooCommerceProductVariation] {
        return try await performRequest(path: "products/\(productId)/variations", queryItems: [URLQueryItem(name: "per_page", value: "100")])
    }
    
    public func fetchCategories(parent: Int? = nil, perPage: Int = 100) async throws -> [WooCommerceCategory] {
        var queryItems = [URLQueryItem(name: "per_page", value: String(perPage))]
        if let parentId = parent { queryItems.append(URLQueryItem(name: "parent", value: String(parentId))) }
        return try await performRequest(path: "products/categories", queryItems: queryItems)
    }
    
    public func fetchOrders(for customerId: Int) async throws -> [WooCommerceOrder] {
        return try await performRequest(path: "orders", queryItems: [URLQueryItem(name: "customer", value: String(customerId))])
    }
    
    public func fetchAttributeDefinitions() async throws -> [WooCommerceAttributeDefinition] {
        return try await performRequest(path: "products/attributes", queryItems: [])
    }
    
    public func fetchAttributeTerms(for attributeId: Int) async throws -> [WooCommerceAttributeTerm] {
        return try await performRequest(path: "products/attributes/\(attributeId)/terms", queryItems: [URLQueryItem(name: "per_page", value: "100")])
    }
    
    // MARK: - Gehärtete Request-Engine
    
    private func performRequest<T: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        // ENDGÜLTIGE KORREKTUR: Der Typ 'T' wird hier explizit deklariert, um sicherzustellen,
        // dass der nachfolgende Aufruf weiß, was er zu dekodieren hat.
        let (decodedObject, _): (T, HTTPURLResponse) = try await performRequestAndGetResponse(path: path, queryItems: queryItems)
        return decodedObject
    }

    private func performRequestAndGetResponse<T: Decodable>(path: String, queryItems: [URLQueryItem]) async throws -> (T, HTTPURLResponse) {
        var components = URLComponents(string: AppConfig.API.WCProxy.base)!
        components.path += "/\(path)"
        components.queryItems = queryItems
        
        guard let url = components.url else { throw WooCommerceAPIError.invalidURL }
        let request = URLRequest(url: url)
        
        return try await executeAndDecode(request: request)
    }
    
    private func executeAndDecode<T: Decodable>(request: URLRequest) async throws -> (T, HTTPURLResponse) {
        var mutableRequest = request
        
        guard let token = authManager.getAuthToken() else { throw WooCommerceAPIError.notAuthenticated }
        mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: mutableRequest)
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.invalidURL }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
            logger.error("API Error [\(httpResponse.statusCode)] auf \(request.url?.absoluteString ?? "N/A"): \(errorResponse?.message ?? "Keine Fehlerdetails.")")
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorResponse?.message, errorCode: errorResponse?.code)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedObject = try decoder.decode(T.self, from: data)
            return (decodedObject, httpResponse)
        } catch {
            logger.error("DECODING FEHLER auf \(request.url?.absoluteString ?? "N/A"): \(error.localizedDescription). Daten: \(String(data: data, encoding: .utf8) ?? "Nicht lesbar")")
            throw WooCommerceAPIError.decodingError(error)
        }
    }
}

