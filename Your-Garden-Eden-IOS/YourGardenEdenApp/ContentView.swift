// DATEI: ContentView.swift
// PFAD: App/ContentView.swift
// VERSION: 11.1 (OPERATION GEISTERAKTION)
// ZWECK: Neutralisierung der unautorisierten Warenkorb-Aktion durch
//        Anpassung der Tab-Navigationslogik.

import SwiftUI

// ===================================================================
// HAUPT-VIEW DER APP (Wurzel der Objekt-Hierarchie)
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

// ===================================================================
// MODERNISIERTE TAB-VIEW (Kern der Operation)
// ===================================================================
struct MainTabView: View {
    // Zugriff auf die globalen Zustände für die Badge-Anzeige.
    @EnvironmentObject private var cartManager: CartAPIManager
    @EnvironmentObject private var wishlistState: WishlistState

    // Lokale Zustände für die Tab-Steuerung und die Navigationspfade.
    @State private var selectedTab: Int = 0
    @State private var homePath = NavigationPath()
    @State private var shopPath = NavigationPath()
    
    var body: some View {
        // Das benutzerdefinierte Binding `tabSelectionBinding` wird für die Steuerung verwendet.
        TabView(selection: tabSelectionBinding) {
            
            // --- TAB 1: HOME ---
            HomeTabView(path: $homePath)
                .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
            
            // --- TAB 2: SHOP ---
            ShopTabView(path: $shopPath)
                .tabItem { Label("Shop", systemImage: "bag.fill") }.tag(1)
            
            // --- TAB 3: WARENKORB ---
            NavigationStack {
                CartView()
                    .withAppNavigation()
            }
            .tabItem { Label("Warenkorb", systemImage: "cart.fill") }.tag(2)
            .badge(cartManager.state.itemCount)
            
            // --- TAB 4: WUNSCHLISTE ---
            NavigationStack {
                WishlistView()
                    .withAppNavigation()
            }
            .tabItem { Label("Wunschliste", systemImage: "heart.fill") }.tag(3)
            .badge(wishlistState.wishlistProductIds.count)
            
            // --- TAB 5: PROFIL ---
            NavigationStack {
                ProfilView()
                    .withAppNavigation()
            }
            .tabItem { Label("Profil", systemImage: "person.fill") }.tag(4)
        }
        .tint(AppTheme.Colors.primary)
        .environment(\.selectedTab, $selectedTab)
    }
    
    // === BEGINN MODIFIKATION ===
    /// Ein benutzerdefiniertes Binding, das modifiziert wurde, um die unautorisierte
    /// Warenkorb-Aktion ("Geisteraktion") zu unterbinden.
    private var tabSelectionBinding: Binding<Int> {
        Binding(
            get: {
                // Gibt einfach den aktuellen Tab zurück.
                self.selectedTab
            },
            set: { newSelection in
                // FRÜHERE LOGIK ZURÜCKGESTELLT: Die Prüfung, ob derselbe Tab erneut angetippt wurde,
                // und das Zurücksetzen des Navigationspfades werden ausgesetzt.
                // Dies ist die direkte Maßnahme zur Neutralisierung des Fehlers, da
                // das programmatische Leeren des Pfades die Geisteraktion ausgelöst hat.
                /*
                if newSelection == self.selectedTab {
                    switch newSelection {
                    case 0:
                        if !homePath.isEmpty {
                            homePath = NavigationPath()
                            LogSentinel.shared.info("Home-Tab erneut angetippt. Navigationspfad zurückgesetzt.")
                        }
                    case 1:
                        if !shopPath.isEmpty {
                            shopPath = NavigationPath()
                            LogSentinel.shared.info("Shop-Tab erneut angetippt. Navigationspfad zurückgesetzt.")
                        }
                    default:
                        break
                    }
                }
                */
                
                // Die Logik ist nun auf das reine Aktualisieren des Tabs reduziert.
                self.selectedTab = newSelection
            }
        )
    }
    // === ENDE MODIFIKATION ===
}

// ===================================================================
// HILFSSTRUKTUREN FÜR TAB-AUSWAHL (unverändert)
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
