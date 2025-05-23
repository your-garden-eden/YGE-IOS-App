// Your-Garden-Eden-IOS/Models/FirebaseFunctionPayloads/CreateOrLinkWooCommerceCustomerRequest.swift
import Foundation

struct CreateOrLinkWooCommerceCustomerRequest: Encodable {
    let firebaseUid: String
    let email: String
    let firstName: String?
    let lastName: String?
}
