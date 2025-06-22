//
//  OrderSummary.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.06.25.
//


// DATEI: OrderModels.swift
// PFAD: Models/Order/OrderModels.swift
// VERSION: STAMMDATEN 1.0
// STATUS: NEU

import Foundation

struct OrderSummary: Codable, Identifiable, Hashable {
    let id: String
    let orderNumber: String
    let orderDate: Date
    let status: String
    let totalPrice: String
    let currency: String

    enum CodingKeys: String, CodingKey {
        case id, orderNumber, orderDate, status, totalPrice, currency
    }
}

struct OrderDetail: Codable, Identifiable {
    let id: String
    let orderNumber: String
    let orderDate: Date
    let status: String
    let totalPrice: String
    let currency: String
    let shippingAddress: ShippingAddress
    let lineItems: [LineItem]

    enum CodingKeys: String, CodingKey {
        case id, orderNumber, orderDate, status, totalPrice, currency, shippingAddress, lineItems
    }
}

extension OrderDetail {
    struct ShippingAddress: Codable {
        let street: String
        let zipCode: String
        let city: String
        let country: String
    }

    struct LineItem: Codable, Identifiable {
        var id: String { productId }
        let productId: String
        let productName: String
        let quantity: Int
        let price: String
    }
}