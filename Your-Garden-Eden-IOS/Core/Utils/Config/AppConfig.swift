//
//  AppConfig.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.05.25.
//


// YGE-IOS-App/Core/Config/AppConfig.swift
import Foundation

struct AppConfig {
    struct WooCommerce {
        // Basis-URL für die Standard WooCommerce REST API v3 (Produkte, Kategorien etc.)
        static let coreApiBaseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com/wp-json/wc/v3/"

        // Basis-URL für die WooCommerce Store API (Warenkorb, Checkout etc.)
        static let storeApiBaseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com/wp-json/wc/store/v1/"

        // 🚨 ACHTUNG: Consumer Key & Secret hier NICHT speichern!
        // static let consumerKey = "DEIN_KEY" // <- NICHT MACHEN
        // static let consumerSecret = "DEIN_SECRET" // <- NICHT MACHEN
    }

    struct Firebase {
        static let functionsRegion = "europe-west1" // Aus Angular environment.ts
        // Weitere Firebase-spezifische Konfigurationen, falls nötig
    }
}