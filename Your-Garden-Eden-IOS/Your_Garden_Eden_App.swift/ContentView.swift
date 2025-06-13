// Dateiname: ContentView.swift

import SwiftUI

struct ContentView: View {
    
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var productViewModel = ProductViewModel()
    
    private var authManager = AuthManager.shared
    private var cartAPIManager = CartAPIManager.shared
    
    @StateObject private var wishlistState: WishlistState

    init() {
        _wishlistState = StateObject(wrappedValue: WishlistState(authManager: AuthManager.shared))
    }

    var body: some View {
        MainTabView()
            .environmentObject(authManager)
            .environmentObject(cartAPIManager)
            .environmentObject(categoryViewModel)
            .environmentObject(productViewModel)
            .environmentObject(wishlistState)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView().applyNavDestinations() }
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            NavigationStack { CategoryListView().applyNavDestinations() }
                .tabItem { Label("Shop", systemImage: "bag.fill") }
            
            NavigationStack { CartView().applyNavDestinations() }
                .tabItem { Label("Warenkorb", systemImage: "cart.fill") }
            
            NavigationStack { WishlistView().applyNavDestinations() }
                .tabItem { Label("Wunschliste", systemImage: "heart.fill") }
            
            NavigationStack { ProfilView().applyNavDestinations() }
                .tabItem { Label("Profil", systemImage: "person.fill") }
        }
    }
}


private extension View {
    func applyNavDestinations() -> some View {
        self.navigationDestination(for: WooCommerceProduct.self) { product in
            ProductDetailView(product: product)
        }
        .navigationDestination(for: WooCommerceCategory.self) { category in
            CategoryDetailView(category: category)
        }
        .navigationDestination(for: DisplayableMainCategory.self) { category in
             SubCategoryListView(
                 selectedMainCategoryAppItem: category.appItem,
                 parentWooCommerceCategoryID: category.id
             )
        }
        // KORREKTUR: Verwendet jetzt den globalen, eindeutigen Typ.
        .navigationDestination(for: DisplayableSubCategory.self) { subCategory in
            let tempCategory = WooCommerceCategory(
                id: subCategory.id, name: subCategory.label, slug: "", parent: 0,
                description: "", display: "", image: nil, menuOrder: 0, count: subCategory.count
            )
            CategoryDetailView(category: tempCategory)
        }
        .navigationDestination(for: ProductVariationData.self) { data in
            ProductOptionsView(product: data.product, variations: data.variations)
        }
        .navigationDestination(for: CheckoutView.self) { checkoutView in
             checkoutView
        }
    }
}


struct ProductVariationData: Hashable {
    let product: WooCommerceProduct
    let variations: [WooCommerceProductVariation]
}
