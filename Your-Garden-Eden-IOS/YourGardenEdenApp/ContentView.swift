// Path: Your-Garden-Eden-IOS/App/ContentView.swift
// VERSION 5.0 (FINAL - Correct Modifier Placement)

import SwiftUI

// ===================================================================
// HAUPT-VIEW DER APP
// ===================================================================
struct ContentView: View {
    // Globale Zustands-Manager, die an die gesamte App weitergegeben werden.
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartManager = CartAPIManager.shared
    @StateObject private var wishlistState = WishlistState()
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var productViewModel = ProductViewModel()

    var body: some View {
        // Die MainTabView ist die Wurzel der Benutzeroberfläche.
        MainTabView()
            .environmentObject(authManager)
            .environmentObject(cartManager)
            .environmentObject(wishlistState)
            .environmentObject(categoryViewModel)
            .environmentObject(productViewModel)
            .task {
                await loadInitialData()
            }
    }

    private func loadInitialData() async {
        print("▶️ ContentView: Starting initial data load...")
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await categoryViewModel.fetchTopLevelCategories() }
            group.addTask { await productViewModel.fetchBestsellers() }
            group.addTask { await cartManager.initializeAndFetchCart() }
        }
        print("✅ ContentView: Initial data loading complete.")
    }
}

// ===================================================================
// HAUPT-TAB-NAVIGATION (FINAL KORRIGIERT)
// ===================================================================
struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // --- TAB 1: HOME ---
            NavigationStack {
                HomeView()
                    .withAppNavigation() // KORREKT: Modifier an der View INNERHALB des Stacks.
            }
            .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
            
            // --- TAB 2: SHOP ---
            NavigationStack {
                ShopView()
                    .withAppNavigation() // KORREKT: Modifier an der View INNERHALB des Stacks.
            }
            .tabItem { Label("Shop", systemImage: "bag.fill") }.tag(1)
            
            // --- TAB 3: WARENKORB ---
            NavigationStack {
                CartView()
                    .withAppNavigation() // KORREKT: Modifier an der View INNERHALB des Stacks.
            }
            .tabItem { Label("Warenkorb", systemImage: "cart.fill") }.tag(2)
            
            // --- TAB 4: WUNSCHLISTE ---
            NavigationStack {
                WishlistView()
                    .withAppNavigation() // KORREKT: Modifier an der View INNERHALB des Stacks.
            }
            .tabItem { Label("Wunschliste", systemImage: "heart.fill") }.tag(3)
            
            // --- TAB 5: PROFIL ---
            NavigationStack {
                ProfilView()
                    // Hier ist der Modifier nicht zwingend nötig, aber schadet auch nicht.
                    .withAppNavigation()
            }
            .tabItem { Label("Profil", systemImage: "person.fill") }.tag(4)
        }
        .environment(\.selectedTab, $selectedTab)
    }
}

// ===================================================================
// HILFSSTRUKTUREN FÜR TAB-AUSWAHL (UNVERÄNDERT)
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
