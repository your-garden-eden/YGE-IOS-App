// DATEI: WooCommerceAPIManager.swift
// PFAD: Services/WooCommerceAPIManager.swift
// VERSION: DIAGNOSEMODUS 1.0 - OPERATION "GEISTERSIGNAL"

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
    }
    
    func fetchProducts(params: ProductFilterParameters, page: Int = 1, perPage: Int = 20) async throws -> WooCommerceProductsResponseContainer {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        if let orderBy = params.orderBy, let order = params.order {
            queryItems.append(URLQueryItem(name: "orderby", value: orderBy))
            queryItems.append(URLQueryItem(name: "order", value: order))
        }
        
        if let catId = params.categoryId { queryItems.append(URLQueryItem(name: "category", value: String(catId))) }
        if let onSale = params.onSale { queryItems.append(URLQueryItem(name: "on_sale", value: String(onSale))) }
        if let featured = params.featured { queryItems.append(URLQueryItem(name: "featured", value: String(featured))) }
        if let search = params.searchQuery, !search.isEmpty { queryItems.append(URLQueryItem(name: "search", value: search)) }
        if let includeIds = params.include, !includeIds.isEmpty { queryItems.append(URLQueryItem(name: "include", value: includeIds.map(String.init).joined(separator: ","))) }
        
        if let stock = params.stockStatus { queryItems.append(URLQueryItem(name: "stock_status", value: stock.rawValue)) }
        if let type = params.productType { queryItems.append(URLQueryItem(name: "type", value: type)) }
        if let min = params.minPrice { queryItems.append(URLQueryItem(name: "min_price", value: min)) }
        if let max = params.maxPrice { queryItems.append(URLQueryItem(name: "max_price", value: max)) }
        
        let (products, httpResponse) = try await performCoreRequest(path: "products", queryItems: queryItems, decodingType: [WooCommerceProduct].self)
        let totalPages = Int(httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages") ?? "1") ?? 1
        let totalCount = Int(httpResponse.value(forHTTPHeaderField: "X-WP-Total") ?? "0") ?? 0
        return WooCommerceProductsResponseContainer(products: products, totalPages: totalPages, totalCount: totalCount)
    }
    
    func fetchProductVariations(productId: Int) async throws -> [WooCommerceProductVariation] {
        let (variations, _) = try await performCoreRequest(path: "products/\(productId)/variations", queryItems: [URLQueryItem(name: "per_page", value: "100")], decodingType: [WooCommerceProductVariation].self)
        return variations
    }
    
    func fetchCategories(parent: Int? = nil) async throws -> [WooCommerceCategory] {
        var queryItems = [URLQueryItem(name: "per_page", value: "100"), URLQueryItem(name: "hide_empty", value: "true")]
        if let parentId = parent { queryItems.append(URLQueryItem(name: "parent", value: String(parentId))) }
        let (categories, _) = try await performCoreRequest(path: "products/categories", queryItems: queryItems, decodingType: [WooCommerceCategory].self)
        return categories
    }

    func fetchAttributeDefinitions() async throws -> [WooCommerceAttributeDefinition] {
        let (definitions, _) = try await performCoreRequest(path: "products/attributes", queryItems: [], decodingType: [WooCommerceAttributeDefinition].self)
        return definitions
    }
    
    func fetchAttributeTerms(for attributeId: Int) async throws -> [WooCommerceAttributeTerm] {
        let queryItems = [URLQueryItem(name: "per_page", value: "100"), URLQueryItem(name: "hide_empty", value: "true")]
        let (terms, _) = try await performCoreRequest(path: "products/attributes/\(attributeId)/terms", queryItems: queryItems, decodingType: [WooCommerceAttributeTerm].self)
        return terms
    }

    private func performCoreRequest<T: Decodable>(path: String, queryItems: [URLQueryItem], decodingType: T.Type) async throws -> (T, HTTPURLResponse) {
        var components = URLComponents(string: AppConfig.WooCommerce.CoreAPI.base + path)!
        components.queryItems = addAuthQueryItems(to: queryItems)
        return try await performRequest(url: components.url, httpMethod: "GET", decodingType: decodingType)
    }

    private func performRequest<T: Decodable>(url: URL?, httpMethod: String, body: Data? = nil, headers: [String: String] = [:], decodingType: T.Type) async throws -> (T, HTTPURLResponse) {
        guard let url = url else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = body
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            let (data, response) = try await session.data(for: request)

            // --- BEGINN DIAGNOSE-SONDE FÜR OPERATION "GEISTERSIGNAL" ---
            // Diese Sonde gibt den rohen JSON-String aus, bevor er dekodiert wird.
            // Dies ist entscheidend, um alle von der API gesendeten Felder zu identifizieren.
            if let jsonString = String(data: data, encoding: .utf8) {
                print("\n\n--- 📡 OPERATION 'GEISTERSIGNAL': ROHDATEN-ABFANGPROTOKOLL FÜR \(url.path) 📡 ---")
                print(jsonString)
                print("--- 📡 ENDE DES ABFANGPROTOKOLLS 📡 ---\n\n")
            }
            // --- ENDE DIAGNOSE-SONDE ---

            guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])) }
            guard (200...299).contains(httpResponse.statusCode) else {
                let (message, code) = parseWooCommerceError(from: data)
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: message, errorCode: code)
            }
            if data.isEmpty && T.self != String.self { throw WooCommerceAPIError.noData }
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return (decodedObject, httpResponse)
        } catch let error as DecodingError {
            LogSentinel.shared.error("DECODING ERROR for URL: \(url.absoluteString)\nDetails: \(error)")
            throw WooCommerceAPIError.decodingError(error)
        } catch { throw WooCommerceAPIError.underlying(error) }
    }
    
    private func addAuthQueryItems(to items: [URLQueryItem]) -> [URLQueryItem] {
        var newItems = items
        newItems.append(URLQueryItem(name: "consumer_key", value: self.consumerKey))
        newItems.append(URLQueryItem(name: "consumer_secret", value: self.consumerSecret))
        return newItems
    }
    
    private func parseWooCommerceError(from data: Data) -> (message: String?, code: String?) {
        let error = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
        return (error?.message, error?.code)
    }
}
