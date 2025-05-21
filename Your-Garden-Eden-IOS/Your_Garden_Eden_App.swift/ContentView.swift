import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = FirebaseAuthManager()
    @State private var showingAuthSheet = false

    var body: some View {
        Group {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                ProductCategoryListView() // HIER DIE ÄNDERUNG
                    .tabItem {
                        Label("Shop", systemImage: "bag.fill")
                    }
                    .tag(1)

                Text("Warenkorb Placeholder")
                    .tabItem {
                        Label("Warenkorb", systemImage: "cart.fill")
                    }
                    .tag(2)
                // ... Rest der Tabs ...
                Text("Wunschliste Placeholder")
                    .tabItem {
                        Label("Wunschliste", systemImage: "heart.fill")
                    }
                    .tag(3)

                Text("Profil Placeholder")
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
                    .tag(4)
            }
        }
        .environmentObject(authManager)
        // ... Rest der .onAppear, .sheet, .onChange Modifier ...
    }
}
