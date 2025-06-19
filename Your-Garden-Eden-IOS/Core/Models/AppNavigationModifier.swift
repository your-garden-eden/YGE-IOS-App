// DATEI: AppNavigationModifier.swift
// PFAD: Core/Navigation/AppNavigationModifier.swift
// VERSION: 1.5 (VALIDIERT & FINAL)

import SwiftUI

/// Ein wiederverwendbares Paket von Navigationszielen für die gesamte App.
struct AppNavigationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: WooCommerceProduct.self) { product in
                ProductDetailView(product: product)
            }
            .navigationDestination(for: WooCommerceCategory.self) { category in
                CategoryLandingView(category: category)
            }
            .navigationDestination(for: ProductVariationData.self) { data in
                ProductOptionsView(product: data.product, variations: data.variations)
            }
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
    func withAppNavigation() -> some View {
        self.modifier(AppNavigationModifier())
    }
}
