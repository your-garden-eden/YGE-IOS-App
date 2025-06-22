// DATEI: ContentView.swift
// PFAD: App/ContentView.swift
// VERSION: EINHEITSKOMMANDO 1.0 (BEREINIGT)

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartManager = CartAPIManager.shared
    @StateObject private var wishlistState = WishlistState.shared
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        switch authManager.authState {
        case .initializing:
            VStack {
                ProgressView()
                Text("Verbinde mit dem Shop...")
                    .foregroundColor(.secondary)
                    .padding()
            }
        case .guest, .authenticated:
            MainTabView()
                .environmentObject(authManager)
                .environmentObject(cartManager)
                .environmentObject(wishlistState)
                .environmentObject(homeViewModel)
                .task {
                    // --- BEGINN MODIFIKATION ---
                    // Der redundante Aufruf zum Laden des Warenkorbs wird entfernt.
                    // Diese Verantwortung liegt nun ausschließlich beim reaktiven
                    // Beobachter im CartAPIManager, der auf Auth-Änderungen reagiert.
                    await homeViewModel.loadInitialData()
                    // await cartManager.getCart(showLoadingIndicator: false) <- ENTFERNT
                    // --- ENDE MODIFIKATION ---
                }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    @EnvironmentObject private var wishlistState: WishlistState

    @State private var selectedTab: Int = 0
    @State private var homePath = NavigationPath()
    @State private var shopPath = NavigationPath()
    
    var body: some View {
        TabView(selection: tabSelectionBinding) {
            HomeTabView(path: $homePath).tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
            ShopTabView(path: $shopPath).tabItem { Label("Shop", systemImage: "bag.fill") }.tag(1)
            NavigationStack { CartView().withAppNavigation() }.tabItem { Label("Warenkorb", systemImage: "cart.fill") }.tag(2).badge(cartManager.state.itemCount)
            NavigationStack { WishlistView().withAppNavigation() }.tabItem { Label("Wunschliste", systemImage: "heart.fill") }.tag(3).badge(wishlistState.wishlistProductIds.count)
            NavigationStack { ProfilView().withAppNavigation() }.tabItem { Label("Profil", systemImage: "person.fill") }.tag(4)
        }
        .tint(AppTheme.Colors.primary)
        .environment(\.selectedTab, $selectedTab)
    }
    
    private var tabSelectionBinding: Binding<Int> {
        Binding( get: { self.selectedTab }, set: { newSelection in self.selectedTab = newSelection })
    }
}

private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var selectedTab: Binding<Int> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}
