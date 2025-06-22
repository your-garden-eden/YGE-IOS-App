// DATEI: ContentView.swift
// PFAD: App/ContentView.swift
// VERSION: ADLERAUGE 1.0
// STATUS: MODIFIZIERT

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartManager = CartAPIManager.shared
    @StateObject private var wishlistState = WishlistState()
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        // MODIFIZIERT: Nutzt das neue AuthState-Enum für eine robuste Zustandsanzeige.
        switch authManager.authState {
        case .initializing:
            // Zeigt einen Ladebildschirm, während der erste Token geladen wird.
            VStack {
                ProgressView()
                Text("Verbinde mit dem Shop...")
                    .foregroundColor(.secondary)
                    .padding()
            }
        case .guest, .authenticated:
            // Zeigt die Haupt-App erst an, wenn ein stabiler Zustand erreicht ist.
            MainTabView()
                .environmentObject(authManager)
                .environmentObject(cartManager)
                .environmentObject(wishlistState)
                .environmentObject(homeViewModel)
                .task {
                    // Diese Aufgaben werden nun garantiert in einem sicheren Kontext ausgeführt.
                    await homeViewModel.loadInitialData()
                    await cartManager.getCart(showLoadingIndicator: false)
                }
        }
    }
}

// [Rest der Datei (MainTabView, etc.) bleibt unverändert]
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
