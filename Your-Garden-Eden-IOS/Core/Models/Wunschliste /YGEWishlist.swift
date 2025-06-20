//
//  YGEWishlist.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: WishlistModels.swift
// PFAD: Models/WishlistModels.swift
// ZWECK: Definiert die Datenstrukturen für die benutzerdefinierte Wunschliste (Wishlist).

import Foundation

public struct YGEWishlist: Codable, Hashable {
    public let items: [YGEWishlistItem]
}

public struct YGEWishlistItem: Codable, Hashable, Identifiable {
    public var id: String { "\(productId)-\(variationId ?? 0)" }
    public let productId: Int
    public let variationId: Int?
    public let addedAt: String
    
    enum CodingKeys: String, CodingKey {
        case productId, variationId, addedAt
    }
}