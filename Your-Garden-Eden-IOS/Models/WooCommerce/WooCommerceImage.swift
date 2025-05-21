import Foundation

struct WooCommerceImage: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let dateCreated: String
    let dateCreatedGmt: String
    let dateModified: String
    let dateModifiedGmt: String
    let src: String
    let name: String
    let alt: String
    let position: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case dateCreated = "date_created"
        case dateCreatedGmt = "date_created_gmt"
        case dateModified = "date_modified"
        case dateModifiedGmt = "date_modified_gmt"
        case src, name, alt, position
    }
    // Optional: Placeholder für Previews, falls benötigt
    static var placeholder: WooCommerceImage {
        WooCommerceImage(id: 0, dateCreated: "", dateCreatedGmt: "", dateModified: "", dateModifiedGmt: "", src: "https://via.placeholder.com/150/CCCCCC/FFFFFF?Text=Img", name: "Placeholder", alt: "Placeholder Image", position: 0)
    }
}
