//
//  WooCommerceErrorResponse.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.05.25.
//


// YGE-IOS-App/Core/Models/WooCommerce/Shared/WooCommerceErrorResponse.swift
import Foundation

struct WooCommerceErrorResponse: Codable {
    let code: String?
    let message: String?
    let data: ErrorData? // Kann auch optional sein, je nach API

    struct ErrorData: Codable {
        let status: Int?
    }
}