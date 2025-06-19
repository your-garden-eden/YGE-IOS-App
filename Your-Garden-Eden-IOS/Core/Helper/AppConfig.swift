// DATEI: AppConfig.swift
// PFAD: Helper/AppConfig.swift
// VERSION: PHOENIX 2.1 (OPERATION TABULA RASA INTEGRIERT)

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
    }

    public struct Auth {
        private static let base = "\(baseURL)\(baseAPIPath)/simple-jwt-login/v1"
        
        public static let login = "\(base)/auth"
        public static let register = "\(base)/users"
        public static let registrationKey = "YGE-app-register-user"
    }
}
