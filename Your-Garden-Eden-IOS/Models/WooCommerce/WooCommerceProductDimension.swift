import Foundation

struct WooCommerceProductDimension: Codable, Hashable, Equatable {
    let length: String
    let width: String
    let height: String

    static var placeholder: WooCommerceProductDimension {
        WooCommerceProductDimension(length: "0", width: "0", height: "0")
    }
}
