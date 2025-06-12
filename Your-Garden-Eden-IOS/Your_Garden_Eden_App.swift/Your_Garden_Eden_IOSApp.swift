//
//  Your_Garden_Eden_IOSApp.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on ... // Dein Erstellungsdatum
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Your_Garden_Eden_IOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartAPIManager = CartAPIManager.shared
    @StateObject private var wishlistState: WishlistState
    // --- START ÄNDERUNG 1.1 ---
    // Der CategoryViewModel wird hier als zentrale Instanz (Single Source of Truth) erstellt.
    // Er existiert nun für die gesamte Lebensdauer der App und wird nicht mehr in der View neu erstellt.
    @StateObject private var categoryViewModel = CategoryViewModel()
    // --- ENDE ÄNDERUNG 1.1 ---

    init() {
        let authManager = AuthManager.shared
        _wishlistState = StateObject(wrappedValue: WishlistState(authManager: authManager))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(cartAPIManager)
                .environmentObject(wishlistState)
                // --- START ÄNDERUNG 1.2 ---
                // Der zentrale categoryViewModel wird hier in die Environment der gesamten App injiziert.
                // Jede View, die ihn benötigt, kann nun darauf zugreifen.
                .environmentObject(categoryViewModel)
                // --- ENDE ÄNDERUNG 1.2 ---
        }
    }
}
