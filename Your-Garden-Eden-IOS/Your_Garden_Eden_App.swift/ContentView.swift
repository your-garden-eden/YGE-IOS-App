// ContentView.swift
import SwiftUI

struct ContentView: View {
    // MARK: - State Objects für globale Manager/States
    @StateObject private var authManager = FirebaseAuthManager.shared
    @StateObject private var cartAPIManager = CartAPIManager.shared
    @StateObject private var wishlistState: WishlistState

    // MARK: - Initializer
    init() {
        let sharedAuthManager = FirebaseAuthManager.shared
        _wishlistState = StateObject(wrappedValue: WishlistState(authManager: sharedAuthManager))
        
        print("ContentView initialized. AuthManager, CartAPIManager, and WishlistState are set up.")
        
        // Optionale globale UI-Konfigurationen
        // setupGlobalAppearance()
    }

    // MARK: - Body
    var body: some View {
        Group {
            TabView {
                HomeView() // Aus Features/Home/Views/
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                CategoryListView() // Aus Core/Categories/Views/ (zeigt die 8 Hauptkategorien)
                    .tabItem {
                        Label("Shop", systemImage: "bag.fill")
                    }
                    .tag(1)

                // HIER IST DER AUFRUF, DER DEN FEHLER VERURSACHT, WENN CartView NICHT DEFINIERT IST
                CartView() // Aus Features/Cart/Views/
                    .tabItem {
                        Label("Warenkorb", systemImage: "cart.fill")
                    }
                    .tag(2)
                
                WishlistView() // Aus Features/Wishlist/Views/
                    .tabItem {
                        Label("Wunschliste", systemImage: "heart.fill")
                    }
                    .tag(3)

                ProfilView() // Aus Features/Profile/Views/
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
                    .tag(4)
            }
            // Stelle die globalen States/Manager allen Tabs und deren Kind-Views zur Verfügung
            .environmentObject(authManager)
            .environmentObject(cartAPIManager)
            .environmentObject(wishlistState)
        }
    }

    // Optionale Hilfsfunktion für globale UI-Anpassungen
    // private func setupGlobalAppearance() { /* ... */ }
}

// MARK: - Preview Provider
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
