// DATEI: ProductDisplayable.swift
// PFAD: Models/Protocols/ProductDisplayable.swift
// VERSION: FINAL - Alle Operationen integriert.

import Foundation
import SwiftUI

public protocol ProductDisplayable {
    
    var displayId: Int { get }
    var displayName: String { get }
    var displayImageURL: URL? { get }
    var displayPrice: String { get }
    var displayStrikethroughPrice: String? { get }
    var displayStockStatus: (text: String, color: SwiftUI.Color) { get }
    
    func asWooCommerceProduct() -> WooCommerceProduct?
}
