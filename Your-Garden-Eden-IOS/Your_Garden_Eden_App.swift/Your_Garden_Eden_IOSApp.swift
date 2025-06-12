// Your_Garden_Eden_IOSApp.swift

import SwiftUI
import Firebase

@main
struct Your_Garden_Eden_IOSApp: App {
    // Alle globalen Manager werden hier EINMAL erstellt und gehören der App.
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartAPIManager = CartAPIManager.shared
    @StateObject private var wishlistState = WishlistState(authManager: AuthManager.shared)

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Hier werden die Manager an die gesamte View-Hierarchie übergeben.
                .environmentObject(authManager)
                .environmentObject(cartAPIManager)
                .environmentObject(wishlistState) // <-- DAS IST DIE FEHLENDE/WICHTIGE ZEILE
        }
    }
}
