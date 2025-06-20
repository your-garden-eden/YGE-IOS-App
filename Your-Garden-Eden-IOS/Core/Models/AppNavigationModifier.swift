// DATEI: AppNavigationModifier.swift
// PFAD: Core/Navigation/AppNavigationModifier.swift
// ÄNDERUNG: Der fehlerhafte Handler für `Int.self` wird entfernt, um
//           die nicht unterstützte Navigation zu deaktivieren.

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
            // Der fehlerhafte Handler für Int.self wurde entfernt.
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
