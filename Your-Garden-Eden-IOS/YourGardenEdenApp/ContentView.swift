// DATEI: ContentView.swift
// PFAD: App/ContentView.swift
// VERSION: 11.0 (OPERATION HORIZONT)
// ZWECK: Der Haupteinstiegspunkt der Anwendung mit einer vollständig
//        modernisierten und funktionalen Tab-Navigation.

import SwiftUI

// ===================================================================
// HAUPT-VIEW DER APP (Wurzel der Objekt-Hierarchie)
// ===================================================================
struct ContentView: View {
    // Globale Zustands-Manager, die an die gesamte App weitergegeben werden.
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartManager = CartAPIManager.shared
    @StateObject private var wishlistState = WishlistState() // Behält die von Ihnen vorgegebene Initialisierung bei.
    
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
            // Verwendet den neuen Container, um den Pfad steuerbar zu machen.
            HomeTabView(path: $homePath)
                .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
            
            // --- TAB 2: SHOP ---
            // Verwendet den neuen Container, um den Pfad steuerbar zu machen.
            ShopTabView(path: $shopPath)
                .tabItem { Label("Shop", systemImage: "bag.fill") }.tag(1)
            
            // --- TAB 3: WARENKORB ---
            NavigationStack {
                CartView()
                    .withAppNavigation()
            }
            .tabItem { Label("Warenkorb", systemImage: "cart.fill") }.tag(2)
            // ANPASSUNG: Badge für Warenkorb-Anzahl hinzugefügt.
            .badge(cartManager.state.itemCount)
            
            // --- TAB 4: WUNSCHLISTE ---
            NavigationStack {
                WishlistView()
                    .withAppNavigation()
            }
            .tabItem { Label("Wunschliste", systemImage: "heart.fill") }.tag(3)
            // ANPASSUNG: Badge für Wunschlisten-Anzahl hinzugefügt.
            .badge(wishlistState.wishlistProductIds.count)
            
            // --- TAB 5: PROFIL ---
            NavigationStack {
                ProfilView()
                    .withAppNavigation()
            }
            .tabItem { Label("Profil", systemImage: "person.fill") }.tag(4)
        }
        // ANPASSUNG: Farbschema für die gesamte Tab-Leiste festgelegt.
        .tint(AppTheme.Colors.primary)
        .environment(\.selectedTab, $selectedTab) // Gibt die Auswahl weiterhin an untergeordnete Views weiter.
    }
    
    /// Ein benutzerdefiniertes Binding, das die Standard-Logik erweitert,
    /// um die Navigations-Anomalie zu beheben.
    private var tabSelectionBinding: Binding<Int> {
        Binding(
            get: {
                // Gibt einfach den aktuellen Tab zurück.
                self.selectedTab
            },
            set: { newSelection in
                if newSelection == self.selectedTab {
                    // Der Benutzer hat denselben Tab erneut angetippt.
                    // Setze den entsprechenden Navigationspfad zurück.
                    switch newSelection {
                    case 0:
                        // Nur zurücksetzen, wenn der Pfad nicht bereits leer ist.
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
                        // Für andere Tabs ist keine Reset-Logik erforderlich.
                        break
                    }
                }
                // Aktualisiere in jedem Fall den ausgewählten Tab.
                self.selectedTab = newSelection
            }
        )
    }
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
