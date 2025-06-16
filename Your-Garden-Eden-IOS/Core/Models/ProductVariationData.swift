//
//  ProductVariationData.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 16.06.25.
//


// Path: Your-Garden-Eden-IOS/Models/ProductVariationData.swift
// VERSION 1.0 (FINAL - Navigation Data Container)

import Foundation

/// Ein einfacher, typsicherer Datencontainer für die Navigation zur Optionsauswahl-Seite.
/// Er bündelt alle Informationen, die die `ProductOptionsView` benötigt.
struct ProductVariationData: Hashable, Identifiable {
    // UUID stellt sicher, dass jede Instanz einzigartig ist, auch wenn Produkt und Variationen gleich sind.
    // Das ist wichtig für die Navigation und Identifizierbarkeit in SwiftUI-Listen.
    let id = UUID()
    let product: WooCommerceProduct
    let variations: [WooCommerceProductVariation]

    // Wir müssen `hash(into:)` und `==` manuell implementieren, da wir nur die ID vergleichen wollen.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ProductVariationData, rhs: ProductVariationData) -> Bool {
        // Zwei Instanzen sind nur gleich, wenn ihre einzigartigen IDs übereinstimmen.
        lhs.id == rhs.id
    }
}