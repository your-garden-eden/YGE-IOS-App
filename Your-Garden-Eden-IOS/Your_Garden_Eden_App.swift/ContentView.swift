// ContentView.swift

import SwiftUI

struct ContentView: View {
    // Die ContentView empfängt die Manager nur noch. Sie besitzt sie nicht.
    // Das @StateObject von früher ist hier nicht mehr nötig.
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var cartAPIManager: CartAPIManager
    @EnvironmentObject var wishlistState: WishlistState

    var body: some View {
        // Der NavigationStack ist die Wurzel der Navigation.
        NavigationStack {
            // Die TabView ist der Inhalt des NavigationStack.
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                
                CategoryListView()
                    .tabItem { Label("Shop", systemImage: "bag.fill") }
                
                CartView() // Du musst sicherstellen, dass diese View existiert
                    .tabItem { Label("Warenkorb", systemImage: "cart.fill") }
                
                WishlistView()
                    .tabItem { Label("Wunschliste", systemImage: "heart.fill") }
                
                ProfilView() // Du musst sicherstellen, dass diese View existiert
                    .tabItem { Label("Profil", systemImage: "person.fill") }
            }
            // HINWEIS: Die Modifier wurden von der TabView hierher verschoben.
        }
        // Die .navigationDestination Modifier gehören direkt zum NavigationStack.
        // Das stellt sicher, dass sie für alle Inhalte innerhalb des Stacks gelten.
        .navigationDestination(for: WooCommerceProduct.self) { product in
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthManager.shared)
            .environmentObject(CartAPIManager.shared)
            .environmentObject(WishlistState(authManager: AuthManager.shared))
    }
}
