// Your-Garden-Eden-IOS/Models/FirebaseFunctionPayloads/CreateOrLinkWooCommerceCustomerResponse.swift
import Foundation

struct CreateOrLinkWooCommerceCustomerResponse: Decodable {
    let wooCommerceCustomerId: Int
    let status: String // Erwartete Werte: "created", "linked", "exists_no_change_needed", "exists_updated_link"
}
