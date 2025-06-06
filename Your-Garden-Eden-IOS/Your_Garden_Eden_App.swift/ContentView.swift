import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = FirebaseAuthManager.shared
    @StateObject private var cartAPIManager = CartAPIManager.shared
    
    // NEU: Wir erstellen unseren neuen, lokalen CartManager als StateObject.
    @StateObject private var cartManager = CartManager.shared
    
    @StateObject private var wishlistState: WishlistState

    init() {
        // Dieser Initializer ist gut so, wie er ist.
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
            // NEU: Wir fügen den lokalen CartManager zur Umgebung hinzu.
            .environmentObject(cartManager)
        }
    }
}
