//
//  WooCommerceProductsResponseContainer.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 23.05.25.
//


// YGE-IOS-App/Core/Models/WooCommerce/CoreAPI/WooCommerceProductsResponseContainer.swift
// (Oder direkt im WooCommerceAPIManager.swift, wenn nur dort verwendet)
import Foundation

struct WooCommerceProductsResponseContainer {
    let products: [WooCommerceProduct]
    let totalPages: Int
    let totalCount: Int
}