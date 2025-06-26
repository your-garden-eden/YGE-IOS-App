// DATEI: AppNavigationModifier.swift
// PFAD: Core/UI/Modifiers/AppNavigationModifier.swift
// ZWECK: Definiert die globalen Navigationsziele für die App.
// STATUS: GEPRÜFT & BESTÄTIGT

import SwiftUI

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
    func withAppNavigation() -> some View {
        self.modifier(AppNavigationModifier())
    }
}
