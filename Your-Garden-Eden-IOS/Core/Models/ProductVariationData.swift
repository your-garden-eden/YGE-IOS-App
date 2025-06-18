//
//  ProductVariationData.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: ProductVariationData.swift
// PFAD: Models/ProductVariationData.swift
// VERSION: 1.0 (FINAL & AUTARK)
// ZWECK: Definiert einen typsicheren Datencontainer für die Navigation zur
//        Produktoptionsansicht (`ProductOptionsView`). Er bündelt alle für
//        die Ziel-View notwendigen Informationen in einem einzigen, navigierbaren Objekt.

import Foundation

public struct ProductVariationData: Hashable, Identifiable {
    /// Eine eindeutige ID stellt sicher, dass SwiftUI jede Navigationsinstanz als einzigartig erkennt,
    /// selbst wenn das Produkt und die Variationen identisch sind. Dies ist essenziell für
    /// eine stabile und vorhersehbare Navigation in Listen und Stacks.
    public let id = UUID()
    
    /// Das übergeordnete variable Produkt, zu dem die Optionen gehören.
    public let product: WooCommerceProduct
    
    /// Eine Liste der verfügbaren Variationen, die an die Optionsansicht übergeben werden.
    public let variations: [WooCommerceProductVariation]

    /// Manuelle Implementierung von `Hashable`, um die Performance zu optimieren und die Eindeutigkeit
    /// sicherzustellen. Nur die `id` wird für den Hash-Wert herangezogen, da sie bereits
    /// die Einzigartigkeit der Instanz garantiert.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Manuelle Implementierung von `Equatable`. Zwei Instanzen von `ProductVariationData` gelten nur dann
    /// als gleich, wenn ihre einzigartigen IDs übereinstimmen. Dies verhindert unerwünschtes
    /// Verhalten bei Vergleichen in SwiftUI.
    public static func == (lhs: ProductVariationData, rhs: ProductVariationData) -> Bool {
        lhs.id == rhs.id
    }
}