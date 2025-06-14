// Path: Your-Garden-Eden-IOS/App/ContentView.swift

import SwiftUI

struct ContentView: View {
    
    // MARK: - Globale App-Zustände (Single Source of Truth)
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartManager = CartAPIManager.shared
    @StateObject private var wishlistState = WishlistState()
    
    // ViewModels, die Daten für mehrere Screens bereitstellen
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var productViewModel = ProductViewModel()

    var body: some View {
        MainTabView()
            // Alle globalen Objekte werden hier als EnvironmentObjects bereitgestellt.
            .environmentObject(authManager)
            .environmentObject(cartManager)
            .environmentObject(wishlistState)
            .environmentObject(categoryViewModel)
            .environmentObject(productViewModel)
            // Der Lademeister. Dieser Task wird EINMAL ausgeführt, wenn die App startet.
            .task {
                await loadInitialData()
            }
    }

    private func loadInitialData() async {
        // Wir verwenden eine Task-Gruppe, um die initialen Daten parallel zu laden.
        print("▶️ ContentView: Starting initial data load...")
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await categoryViewModel.fetchCategories() }
            group.addTask { await productViewModel.fetchBestsellers() }
            group.addTask { await cartManager.initializeAndFetchCart() }
            // Der WishlistState lädt seine Daten selbst, basierend auf dem Auth-Status.
        }
        print("✅ ContentView: Initial data loading complete.")
    }
}


// MARK: - Haupt-Tab-Navigation
struct MainTabView: View {
    // Dieser State steuert, welcher Tab aktiv ist.
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView().applyNavDestinations() }
                .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
            
            NavigationStack { CategoryListView().applyNavDestinations() }
                .tabItem { Label("Shop", systemImage: "bag.fill") }.tag(1)
            
            NavigationStack { CartView().applyNavDestinations() }
                .tabItem { Label("Warenkorb", systemImage: "cart.fill") }.tag(2)
            
            NavigationStack { WishlistView().applyNavDestinations() }
                .tabItem { Label("Wunschliste", systemImage: "heart.fill") }.tag(3)
            
            NavigationStack { ProfilView().applyNavDestinations() }
                .tabItem { Label("Profil", systemImage: "person.fill") }.tag(4)
        }
        // Übergibt den selectedTab an die Child-Views, damit diese den Tab wechseln können.
        .environment(\.selectedTab, $selectedTab)
    }
}

// MARK: - Navigation und Hilfsstrukturen

// Diese Erweiterung zentralisiert die Navigationslogik für die gesamte App.
private extension View {
    func applyNavDestinations() -> some View {
        self
        .navigationDestination(for: WooCommerceProduct.self) { product in
            ProductDetailView(product: product)
        }
        .navigationDestination(for: DisplayableMainCategory.self) { category in
             SubCategoryListView(
                 selectedMainCategoryAppItem: category.appItem,
                 parentWooCommerceCategoryID: category.id
             )
        }
        .navigationDestination(for: DisplayableSubCategory.self) { subCategory in
            let tempCategory = WooCommerceCategory(
                id: subCategory.id, name: subCategory.label, slug: "", parent: 0,
                description: "", display: "", image: nil, menuOrder: 0, count: subCategory.count
            )
            CategoryDetailView(category: tempCategory)
        }
        .navigationDestination(for: ProductVariationData.self) { data in
            ProductOptionsView(product: data.product, variations: data.variations)
        }
        .navigationDestination(for: CheckoutView.self) { checkoutView in
             checkoutView
        }
    }
}

// EnvironmentKey, um den Tab-Index in der View-Hierarchie nach unten zu reichen.
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var selectedTab: Binding<Int> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}
