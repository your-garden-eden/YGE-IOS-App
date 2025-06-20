// DATEI: AppConfig.swift
// PFAD: Helper/AppConfig.swift
// VERSION: GUTSCHEIN 1.0
// ÄNDERUNG: Die Endpunkte für Gutschein-Operationen wurden hinzugefügt.

import Foundation

public enum AppConfig {
    
    private static let baseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com"
    private static let baseAPIPath = "/wp-json"
    
    public struct WooCommerce {
        public struct CoreAPI {
            public static let base = "\(baseURL)\(baseAPIPath)/wc/v3/"
        }
        
        public struct StoreAPI {
            private static let base = "\(baseURL)\(baseAPIPath)/wc/store/v1/"
            
            public struct Cart {
                private static let cartBase = "\(StoreAPI.base)cart"
                
                public static let get = cartBase
                public static let addItem = "\(cartBase)/add-item"
                public static let updateItem = "\(cartBase)/update-item"
                public static let removeItem = "\(cartBase)/remove-item"
                public static let clear = "\(cartBase)/clear"
            }
        }
        
        public static let defaultCurrencySymbol = "€"
    }
    
    public struct YGE {
        private static let base = "\(baseURL)\(baseAPIPath)/your-garden-eden/v1"
        
        public static let wishlist = "\(base)/wishlist"
        public static let addToWishlist = "\(base)/wishlist/item/add"
        public static let removeFromWishlist = "\(base)/wishlist/item/remove"
        public static let userAddresses = "\(base)/user/addresses"
        public static let orderDetails = "\(base)/order-details"
        public static let stageCartForCheckout = "\(base)/stage-cart-for-population"
        
        // === BEGINN MODIFIKATION ===
        // NEU: Endpunkte für Gutschein-Operationen hinzugefügt.
        public static let applyCoupon = "\(base)/cart/apply-coupon"
        public static let removeCoupon = "\(base)/cart/remove-coupon"
        // === ENDE MODIFIKATION ===
    }

    public struct Auth {
        private static let base = "\(baseURL)\(baseAPIPath)/simple-jwt-login/v1"
        
        public static let login = "\(base)/auth"
        public static let register = "\(base)/users"
        public static let registrationKey = "YGE-app-register-user"
    }
}
