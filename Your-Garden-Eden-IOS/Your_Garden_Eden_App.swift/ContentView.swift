// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = FirebaseAuthManager.shared // Greift auf Singleton zu
    @StateObject private var cartAPIManager = CartAPIManager.shared   // Greift auf Singleton zu
    @StateObject private var wishlistState: WishlistState

    init() {
        // Initialisiere wishlistState hier, da es von authManager abhängt.
        _wishlistState = StateObject(wrappedValue: WishlistState(authManager: FirebaseAuthManager.shared))
        print("ContentView initialized, global states created using singletons.")
    }

    var body: some View {
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                CategoryListView()
                    .tabItem { Label("Shop", systemImage: "bag.fill") }
                    .tag(1)

                CartView() // Ersetze mit deiner echten View
                    .tabItem { Label("Warenkorb", systemImage: "cart.fill") }
                    .tag(2)
                
                WishlistView() // Ersetze mit deiner echten View
                    .tabItem { Label("Wunschliste", systemImage: "heart.fill") }
                    .tag(3)

                ProfilView() // Ersetze mit deiner echten View
                    .tabItem { Label("Profil", systemImage: "person.fill") }
                    .tag(4)
            }
            .environmentObject(authManager)
            .environmentObject(cartAPIManager)
            .environmentObject(wishlistState)
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = FirebaseAuthManager.shared
        let cartAPIManager = CartAPIManager.shared
        let wishlistState = WishlistState(authManager: authManager)

        ContentView()
            .environmentObject(authManager)
            .environmentObject(cartAPIManager)
            .environmentObject(wishlistState)
    }
}
