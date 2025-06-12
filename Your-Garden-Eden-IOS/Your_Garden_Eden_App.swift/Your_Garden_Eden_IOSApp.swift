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

// HINWEIS: @main wurde hinzugefügt. Das behebt den Linker-Fehler.
@main
struct Your_Garden_Eden_IOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authManager = AuthManager.shared
    @StateObject private var cartAPIManager = CartAPIManager.shared
    @StateObject private var wishlistState: WishlistState

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
        }
    }
}
