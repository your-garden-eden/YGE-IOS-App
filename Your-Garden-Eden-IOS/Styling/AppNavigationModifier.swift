// Path: Your-Garden-Eden-IOS/Styling/AppNavigationModifier.swift
// VERSION 2.0 (FINAL - Checkout Navigation Added)

import SwiftUI

/// Ein wiederverwendbares Paket von Navigationszielen für die gesamte App.
/// Dieser Modifier stellt sicher, dass alle NavigationStacks konsistent
/// auf Produktdetails, Kategorien usw. reagieren können.
struct AppNavigationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            // ZIEL 1: Wenn ein `WooCommerceProduct` übergeben wird...
            .navigationDestination(for: WooCommerceProduct.self) { product in
                ProductDetailView(product: product)
            }
            // ZIEL 2: Wenn eine `WooCommerceCategory` übergeben wird...
            .navigationDestination(for: WooCommerceCategory.self) { category in
                CategoryLandingView(category: category)
            }
            // ZIEL 3: Wenn `ProductVariationData` übergeben wird...
            .navigationDestination(for: ProductVariationData.self) { data in
                ProductOptionsView(product: data.product, variations: data.variations)
            }
            // ===================================================================
            // ZIEL 4 (NEU): Wenn eine `CheckoutView` übergeben wird...
            // ===================================================================
            .navigationDestination(for: CheckoutView.self) { checkoutView in
                // ...zeige die übergebene CheckoutView-Instanz an.
                checkoutView
            }
    }
}

// MARK: - Convenience Extension
extension View {
    /// Wendet die Standard-Navigationsziele der App auf eine View an.
    /// Dies ist die bevorzugte Methode, um den AppNavigationModifier zu verwenden.
    func withAppNavigation() -> some View {
        self.modifier(AppNavigationModifier())
    }
}
