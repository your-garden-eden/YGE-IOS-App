// Core/Models/DisplayModels.swift

import Foundation

/// Eine Wrapper-Struktur, die ein Produkt eindeutig identifizierbar macht.
struct IdentifiableDisplayProduct: Identifiable {
    let id = UUID()
    let product: WooCommerceProduct
}

