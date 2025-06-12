// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cartAPIManager: CartAPIManager
    @EnvironmentObject var wishlistState: WishlistState

    var body: some View {
        // Die TabView ist jetzt die äußerste Komponente, damit sie immer sichtbar bleibt.
        TabView {
            // JEDER Tab erhält seinen eigenen, unabhängigen NavigationStack.
            
            NavigationStack {
                HomeView()
                    .applyNavDestinations() // Wendet alle Navigationsregeln an
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            
            NavigationStack {
                CategoryListView()
                    .applyNavDestinations() // Wendet alle Navigationsregeln an
            }
            .tabItem { Label("Shop", systemImage: "bag.fill") }
            
            NavigationStack {
                CartView()
                    .applyNavDestinations() // Wendet alle Navigationsregeln an
            }
            .tabItem { Label("Warenkorb", systemImage: "cart.fill") }
            
            NavigationStack {
                WishlistView()
                    .applyNavDestinations() // Wendet alle Navigationsregeln an
            }
            .tabItem { Label("Wunschliste", systemImage: "heart.fill") }
            
            NavigationStack {
                ProfilView()
                    .applyNavDestinations() // Wendet alle Navigationsregeln an
            }
            .tabItem { Label("Profil", systemImage: "person.fill") }
        }
    }
}

// Die Helfer-Erweiterung bleibt bestehen, um Code-Wiederholung zu vermeiden.
// Sie wendet alle Navigationsziele auf eine gegebene View an.
private extension View {
    func applyNavDestinations() -> some View {
        self.navigationDestination(for: WooCommerceProduct.self) { product in
            ProductDetailView(product: product)
        }
        .navigationDestination(for: WooCommerceCategory.self) { category in
            if let appNavItem = AppNavigationData.findItem(forMainCategorySlug: category.slug) {
                SubCategoryListView(
                    selectedMainCategoryAppItem: appNavItem,
                    parentWooCommerceCategoryID: category.id
                )
            } else {
                CategoryDetailView(category: category)
            }
        }
        .navigationDestination(for: DisplayableMainCategory.self) { category in
             SubCategoryListView(
                 selectedMainCategoryAppItem: category.appItem,
                 parentWooCommerceCategoryID: category.id
             )
        }
        .navigationDestination(for: ProductVariationData.self) { data in
            ProductOptionsView(product: data.product, variations: data.variations)
        }
    }
}

// Die Datenstruktur für die Navigation bleibt unverändert.
struct ProductVariationData: Hashable {
    let product: WooCommerceProduct
    let variations: [WooCommerceProductVariation]
}
