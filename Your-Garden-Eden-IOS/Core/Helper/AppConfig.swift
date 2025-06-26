// DATEI: AppConfig.swift
// PFAD: Core/Configuration/AppConfig.swift
// VERSION: 1.6 (ERWEITERT)
// STATUS: Neuer Endpunkt für Benutzer-Bestellungen hinzugefügt.

import Foundation

public enum AppConfig {
    
    private static let baseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com"
    private static let baseAPIPath = "/wp-json"
    private static let jwtAuthNamespace = "/jwt-auth/v1"
    private static let ygeNamespace = "/your-garden-eden/v1"
    private static let wcStoreNamespace = "/wc/store/v1"
    
    public struct API {
        public struct Auth {
            public static let token = "\(baseURL)\(baseAPIPath)\(jwtAuthNamespace)/token"
            public static let register = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/register"
            public static let requestPasswordReset = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/users/request-password-reset"
            public static let requestUsername = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/users/request-username"
            public static let setNewPassword = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/users/set-new-password"
            public static let changePassword = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/user/change-password"
            public static let guestToken = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/guest-token"
        }
        
        public struct WCProxy {
             public static let base = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/wc-proxy"
             public static let products = "\(base)/products"
             public static let categories = "\(base)/products/categories"
             public static let attributes = "\(base)/products/attributes"
             public static let orders = "\(base)/orders"
        }
        
        public struct WCStore {
            private static let base = "\(baseURL)\(baseAPIPath)\(wcStoreNamespace)"
            public static let cart = "\(base)/cart"
            public static let cartAddItem = "\(base)/cart/add-item"
            public static let cartUpdateItem = "\(base)/cart/update-item"
            public static let cartRemoveItem = "\(base)/cart/remove-item"
            public static let cartApplyCoupon = "\(base)/cart/apply-coupon"
            public static let cartRemoveCoupon = "\(base)/cart/remove-coupon"
        }
        
        public struct YGE {
             public static let userAddresses = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/user/addresses"
             public static let wishlist = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/wishlist"
             public static let addToWishlist = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/wishlist/item/add"
             public static let removeFromWishlist = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/wishlist/item/remove"
             public static let stageCartForPopulation = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/stage-cart-for-population"
             // HINZUGEFÜGT: Der neue, sichere Endpunkt für die Bestellhistorie des Benutzers.
             public static let userOrders = "\(baseURL)\(baseAPIPath)\(ygeNamespace)/user/orders"
        }
    }
    
    public static let defaultCurrencySymbol = "€"
    public static let defaultCurrencyMinorUnit = 2
}
