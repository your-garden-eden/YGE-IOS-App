import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = FirebaseAuthManager.shared
    @StateObject private var cartAPIManager = CartAPIManager.shared
    @StateObject private var wishlistState: WishlistState

    init() {
        // Korrekte Initialisierung: Das WishlistState-Objekt wird mit den
        // Abhängigkeiten (wie dem authManager) erstellt.
        _wishlistState = StateObject(wrappedValue: WishlistState(authManager: FirebaseAuthManager.shared))
        print("✅ ContentView initialized. All managers are set up.")
    }

    var body: some View {
        // Deine Tab-Struktur ist korrekt.
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            CategoryListView()
                .tabItem { Label("Shop", systemImage: "bag.fill") }
                .tag(1)

            CartView()
                .tabItem { Label("Warenkorb", systemImage: "cart.fill") }
                .tag(2)
            
            // Die WishlistView wird hier platziert. Sie wird automatisch
            // das wishlistState-Objekt aus der Umgebung empfangen.
            WishlistView()
                .tabItem { Label("Wunschliste", systemImage: "heart.fill") }
                .tag(3)

            ProfilView()
                .tabItem { Label("Profil", systemImage: "person.fill") }
                .tag(4)
        }
        // Hier werden die zentralen Objekte für die gesamte App verfügbar gemacht.
        // Das ist die "Single Source of Truth".
        .environmentObject(authManager)
        .environmentObject(cartAPIManager)
        .environmentObject(wishlistState)
    }
}
