// DATEI: WishlistModels.swift
// PFAD: Models/WishlistModels.swift
// VERSION: STAMMDATEN 1.0 - WISHLIST-FIX
// STATUS: MODIFIZIERT & GEHÄRTET

import Foundation

public struct YGEWishlist: Codable, Hashable {
    // KORREKTUR: Die 'items'-Eigenschaft ist nun optional, um leere Server-Antworten
    // ohne einen 'DecodingError' verarbeiten zu können.
    public let items: [YGEWishlistItem]?
}

public struct YGEWishlistItem: Codable, Hashable, Identifiable {
    public var id: String { "\(productId)-\(variationId ?? 0)" }
    public let productId: Int
    public let variationId: Int?
    public let addedAt: String
    
    // KORREKTUR: Explizite Definition der CodingKeys, um eine robuste Dekodierung
    // von der Snake-Case-Notation des Servers sicherzustellen.
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case variationId = "variation_id"
        case addedAt = "added_at"
    }
}
