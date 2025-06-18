// DATEI: AppNavigationModifier.swift
// PFAD: Core/Navigation/AppNavigationModifier.swift
// VERSION: PHOENIX 1.3 (VOLLSTÄNDIG & FINAL)

import SwiftUI

/// Ein wiederverwendbares Paket von Navigationszielen für die gesamte App.
/// Dieser Modifier stellt sicher, dass die App weiß, wie sie auf Navigationsanfragen
/// für bestimmte Datentypen reagieren soll.
struct AppNavigationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Wendet den benutzerdefinierten Zurück-Button auf jede View innerhalb des Navigations-Kontextes an.
            .customBackButton()
            
            // Definiert das Navigationsziel für ein Produkt.
            .navigationDestination(for: WooCommerceProduct.self) { product in
                ProductDetailView(product: product)
            }
            // Definiert das Navigationsziel für eine Kategorie.
            .navigationDestination(for: WooCommerceCategory.self) { category in
                CategoryLandingView(category: category)
            }
            // Definiert das Navigationsziel für die Produktoptions-Auswahl.
            // Sobald die Duplikat-Datei entfernt ist, wird dieser Typ korrekt gefunden.
            .navigationDestination(for: ProductVariationData.self) { data in
                ProductOptionsView(product: data.product, variations: data.variations)
            }
            // Definiert das Navigationsziel für allgemeine, nicht-modellbasierte Ziele.
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .checkout:
                    CheckoutView()
                }
            }
    }
}

public extension View {
    /// Wendet die Standard-Navigationsziele der App auf eine View an.
    /// Dies sollte auf die oberste View innerhalb eines `NavigationStack` angewendet werden.
    func withAppNavigation() -> some View {
        self.modifier(AppNavigationModifier())
    }
}
