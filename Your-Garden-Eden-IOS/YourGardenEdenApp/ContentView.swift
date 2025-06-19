// DATEI: ContentView.swift
// PFAD: App/ContentView.swift
// VERSION: 10.0 (MISSION ABGESCHLOSSEN)
// ZWECK: Der Haupteinstiegspunkt der Anwendung in seiner finalen,
//        gereinigten und korrekten Form.

import SwiftUI

// ===================================================================
// HAUPT-VIEW DER APP
// ===================================================================
struct ContentView: View {
    // Globale Zustands-Manager, die an die gesamte App weitergegeben werden.
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartManager = CartAPIManager.shared
    @StateObject private var wishlistState = WishlistState()
    
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        // Die MainTabView ist die Wurzel der Benutzeroberfläche.
        MainTabView()
            .environmentObject(authManager)
            .environmentObject(cartManager)
            .environmentObject(wishlistState)
            .environmentObject(homeViewModel)
            .task {
                await homeViewModel.loadInitialData()
                await cartManager.getCart(showLoadingIndicator: false)
            }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // --- TAB 1: HOME ---
            NavigationStack {
                HomeView()
                    .withAppNavigation()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
            
            // --- TAB 2: SHOP ---
            NavigationStack {
                ShopView()
                    .withAppNavigation()
            }
            .tabItem { Label("Shop", systemImage: "bag.fill") }.tag(1)
            
            // --- TAB 3: WARENKORB ---
            NavigationStack {
                CartView()
                    .withAppNavigation()
            }
            .tabItem { Label("Warenkorb", systemImage: "cart.fill") }.tag(2)
            
            // --- TAB 4: WUNSCHLISTE ---
            NavigationStack {
                WishlistView()
                    .withAppNavigation()
            }
            .tabItem { Label("Wunschliste", systemImage: "heart.fill") }.tag(3)
            
            // --- TAB 5: PROFIL ---
            NavigationStack {
                ProfilView()
                    .withAppNavigation()
            }
            .tabItem { Label("Profil", systemImage: "person.fill") }.tag(4)
        }
        .environment(\.selectedTab, $selectedTab)
    }
}

// ===================================================================
// HILFSSTRUKTUREN FÜR TAB-AUSWAHL
// ===================================================================
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var selectedTab: Binding<Int> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}
