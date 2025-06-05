import SwiftUI

// Dein ContentView ist bereits hervorragend und modern strukturiert.
// Keine Änderungen notwendig. Er dient als perfekte Grundlage.
struct ContentView: View {
    @StateObject private var authManager = FirebaseAuthManager.shared
    @StateObject private var cartAPIManager = CartAPIManager.shared
    @StateObject private var wishlistState: WishlistState

    init() {
        _wishlistState = StateObject(wrappedValue: WishlistState(authManager: FirebaseAuthManager.shared))
        print("ContentView initialized. All managers are set up.")
    }

    var body: some View {
        Group {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                // Jede dieser Views ist die Wurzel für ihren Tab.
                // CategoryListView wird seine eigene NavigationStack enthalten.
                CategoryListView()
                    .tabItem {
                        Label("Shop", systemImage: "bag.fill")
                    }
                    .tag(1)

                CartView()
                    .tabItem {
                        Label("Warenkorb", systemImage: "cart.fill")
                    }
                    .tag(2)
                
                WishlistView()
                    .tabItem {
                        Label("Wunschliste", systemImage: "heart.fill")
                    }
                    .tag(3)

                ProfilView()
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
                    .tag(4)
            }
            .environmentObject(authManager)
            .environmentObject(cartAPIManager)
            .environmentObject(wishlistState)
        }
    }
}
