// DATEI: Enums.swift
// PFAD: Core/Models/Enums.swift
// VERSION: 2.4 (ANGEPASST)
// STATUS: RegistrationPayload korrigiert.

import SwiftUI

// MARK: - Navigation
public enum AppDestination: Hashable {
    case checkout
}

public struct ProductVariationData: Hashable {
    let product: WooCommerceProduct
    let variations: [WooCommerceProductVariation]
}

public struct IdentifiableURL: Identifiable {
    public let id: URL
    public var url: URL { id }
    
    public init(url: URL) {
        self.id = url
    }
}

// MARK: - View State & Context
public enum ViewState: Equatable {
    case loading, showSubCategories, showProducts, empty
    case error(String)
}

public enum ProductListContext: Equatable {
    case categoryId(Int)
    case onSale, featured, byIds([Int]), search(String)
}



public enum ProductSortOption: String, CaseIterable, Identifiable {
    case newest = "Neuheiten"
    case popularity = "Beliebtheit"
    case priceLowToHigh = "Preis: Aufsteigend"
    case priceHighToLow = "Preis: Absteigend"
    public var id: String { self.rawValue }
    
    var apiValue: (orderBy: String, order: String) {
        switch self {
        case .newest: return ("date", "desc")
        case .popularity: return ("popularity", "desc")
        case .priceLowToHigh: return ("price", "asc")
        case .priceHighToLow: return ("price", "desc")
        }
    }
}

public enum ProductTypeFilterOption: String, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
    case all = "Alle Produkte"
    case simple = "Einzelprodukte"
    case variable = "Produkte mit Optionen"
    
    var apiValue: String? {
        switch self {
        case .all: return nil
        case .simple: return "simple"
        case .variable: return "variable"
        }
    }
}

public enum WishlistSortOption: String, CaseIterable, Identifiable {
    case dateAdded = "Neueste zuerst"
    case priceAscending = "Preis: aufsteigend"
    case priceDescending = "Preis: absteigend"
    case nameAscending = "Name: A-Z"
    public var id: String { self.rawValue }
}


// MARK: - UI Enums
public enum StatusIndicatorStyle {
    case error(message: String), success(message: String)
    var message: String { switch self { case .error(let m), .success(let m): return m } }
    var iconName: String { switch self { case .error: return "xmark.circle.fill"; case .success: return "checkmark.circle.fill" } }
    var color: Color { switch self { case .error: return AppTheme.Colors.error; case .success: return AppTheme.Colors.success } }
}

public enum StatusIndicatorDisplayMode {
    case banner, fullScreen
}

public enum LogLevel: String {
    case debug, info, notice, warning, error, fatal
    var icon: String {
        switch self {
        case .debug:   return "🔬"
        case .info:    return "ℹ️"
        case .notice:  return "📝"
        case .warning: return "⚠️"
        case .error:   return "🔴"
        case .fatal:   return "💥"
        }
    }
}

// ===================================================================
// === BEGINN KORREKTUR #5.2                                       ===
// ===================================================================
// Hinzufügen der fehlenden API-Payload und Response-Strukturen,
// um die "Cannot find type"-Fehler zu beheben.

// MARK: - API Payloads
public struct RegistrationPayload: Codable {
    let username: String
    let email: String
    let password: String
    let first_name: String
    let last_name: String
    // ANGEPASST: Fehlende Felder hinzugefügt, um den Fehler "Extra arguments" zu beheben.
    let address_1: String
    let postcode: String
    let city: String
    let billing_country: String
    let billing_phone: String
}

public struct CartItemPayload: Codable {
    let productId: Int
    let variationId: Int
    let quantity: Int
}

public struct StagedCartPayload: Codable {
    let items: [CartItemPayload]
    let billingAddress: BillingAddress
    let shippingAddress: ShippingAddress
}

// MARK: - API Responses
public struct StagedCartResponse: Codable {
    let success: Bool
    let token: String
}
// ===================================================================
// === ENDE KORREKTUR #5.2                                         ===
// ===================================================================
