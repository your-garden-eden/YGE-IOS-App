// DATEI: AppConfig.swift
// PFAD: Helper/AppConfig.swift
// VERSION: PHOENIX 2.0 (FINAL)
// ZWECK: Definiert alle statischen Konfigurationswerte für die Kommunikation mit externen Diensten.
//        Dies ist die zentrale Quelle der Wahrheit für alle API-Endpunkte und Basis-URLs.

import Foundation

public enum AppConfig {
    
    // Die private Basis-URL, von der alle anderen Pfade abgeleitet werden.
    private static let baseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com"
    private static let baseAPIPath = "/wp-json"
    
    // MARK: - WooCommerce API
    /// Kapselt alle Endpunkte, die zur Standard-WooCommerce-REST-API gehören.
    public struct WooCommerce {
        
        /// Endpunkte der Core-API (v3), hauptsächlich für das Backend-Management von Produkten, Kategorien etc.
        public struct CoreAPI {
            public static let base = "\(baseURL)\(baseAPIPath)/wc/v3/"
            // Hier könnten bei Bedarf spezifische Pfade hinzugefügt werden, z.B.
            // public static let products = "\(base)products"
        }
        
        /// Endpunkte der Store-API, optimiert für Frontend-Interaktionen wie den Warenkorb.
        public struct StoreAPI {
            private static let base = "\(baseURL)\(baseAPIPath)/wc/store/v1/"
            
            /// Kapselt alle Warenkorb-bezogenen Endpunkte der Store-API.
            public struct Cart {
                public static let get = "\(base)cart"
                public static let addItem = "\(base)cart/add-item"
                public static let updateItem = "\(base)cart/update-item"
                public static let removeItem = "\(base)cart/remove-item"
            }
        }
        
        /// Das standardmäßig verwendete Währungssymbol in der App.
        public static let defaultCurrencySymbol = "€"
    }
    
    // MARK: - Your Garden Eden (YGE) Custom API
    /// Kapselt alle benutzerdefinierten Endpunkte, die spezifisch für "Your Garden Eden" sind.
    public struct YGE {
        private static let base = "\(baseURL)\(baseAPIPath)/your-garden-eden/v1"
        
        public static let wishlist = "\(base)/wishlist"
        public static let addToWishlist = "\(base)/wishlist/item/add"
        public static let removeFromWishlist = "\(base)/wishlist/item/remove"
        
        public static let userAddresses = "\(base)/user/addresses"
        public static let orderDetails = "\(base)/order-details"
        public static let stageCartForCheckout = "\(base)/stage-cart-for-population"
    }

    // MARK: - JWT Authentifizierungs-API
    /// Kapselt alle Endpunkte für die "Simple JWT Login"-Plugin-API.
    public struct Auth {
        private static let base = "\(baseURL)\(baseAPIPath)/simple-jwt-login/v1"
        
        public static let login = "\(base)/auth"
        public static let register = "\(base)/users"
        // Der geheime Schlüssel zur Aktivierung der Benutzerregistrierung über die API.
        public static let registrationKey = "YGE-app-register-user"
    }
}
