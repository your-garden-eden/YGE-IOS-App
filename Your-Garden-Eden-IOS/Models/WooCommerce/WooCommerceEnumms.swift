// YGE-IOS-App/Core/Models/WooCommerce/Shared/WooCommerceEnums.swift
import Foundation

enum ProductType: String, Codable, Hashable, CaseIterable {
    case simple
    case variable
    case grouped
    case external
    // Möglicherweise weitere Typen, die deine API zurückgibt
}

enum StockStatus: String, Codable, Hashable, CaseIterable {
    case instock      // API sendet "instock"
    case outofstock   // API sendet "outofstock"
    case onbackorder  // API sendet "onbackorder"
}

// Du könntest hier auch andere geteilte Enums platzieren, die nicht direkt Fehler sind,
// z.B. für `product.status` ("publish", "draft" etc.) oder `product.taxStatus`.
