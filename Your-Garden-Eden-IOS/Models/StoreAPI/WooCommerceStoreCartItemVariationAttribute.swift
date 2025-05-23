//
//  WooCommerceStoreCartItemVariationAttribute.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.05.25.
//


// YGE-IOS-App/Core/Models/WooCommerce/StoreAPI/WooCommerceStoreCartItemVariationAttribute.swift
import Foundation

struct WooCommerceStoreCartItemVariationAttribute: Codable, Hashable {
    let attribute: String
    let value: String
}