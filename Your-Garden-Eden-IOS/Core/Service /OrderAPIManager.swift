//
//  OrderAPIManager.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.06.25.
//


// DATEI: OrderAPIManager.swift
// PFAD: Manager/OrderAPIManager.swift
// VERSION: STAMMDATEN 1.0
// STATUS: NEU

import Foundation

@MainActor
class OrderAPIManager {
    static let shared = OrderAPIManager()
    private let apiManager = WooCommerceAPIManager.shared
    
    // Annahme: Es wird eine Basis-URL für die benutzerdefinierten Endpunkte in AppConfig benötigt.
    // Da diese nicht explizit vorhanden ist, wird die URL hier zusammengesetzt.
    // Dies sollte idealerweise in AppConfig zentralisiert werden.
    private let ordersBaseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com/api/user/orders"

    private init() {}

    func fetchOrders() async throws -> [OrderSummary] {
        return try await apiManager.performCustomAuthenticatedRequest(
            urlString: ordersBaseURL,
            method: "GET",
            responseType: [OrderSummary].self
        )
    }

    func fetchOrderDetail(id: String) async throws -> OrderDetail {
        let detailURL = "\(ordersBaseURL)/\(id)"
        return try await apiManager.performCustomAuthenticatedRequest(
            urlString: detailURL,
            method: "GET",
            responseType: OrderDetail.self
        )
    }
}