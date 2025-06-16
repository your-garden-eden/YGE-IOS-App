import Foundation

struct AppConfig {
    
    // Basis-Domain für alle API-Aufrufe
    private static let baseURL = "https://your-garden-eden-4ujzpfm5qt.live-website.com"
    
    // MARK: - Standard WooCommerce API Konfiguration
    struct WooCommerce {
        static let coreApiBaseURL = "\(baseURL)/wp-json/wc/v3/"
        static let storeApiBaseURL = "\(baseURL)/wp-json/wc/store/" // v1 wird direkt angehängt, wo benötigt
        static let defaultCurrencySymbol = "€"
    }
    
    // MARK: - Your Garden Eden (YGE) Custom API Endpoints
    // Diese Endpunkte wurden aus der functions.php extrahiert.
    struct YGE {
        private static let customApiBaseURL = "\(baseURL)/wp-json/your-garden-eden/v1"
        
        // --- Warenkorb (User-gebunden, via JWT) ---
        static let cartEndpoint = "\(customApiBaseURL)/cart" // GET, DELETE
        static let cartAddItemEndpoint = "\(customApiBaseURL)/cart/item" // POST (add/update)
        static let cartRemoveItemEndpoint = "\(customApiBaseURL)/cart/item/remove" // POST (remove)
        
        // --- Wunschliste (User-gebunden, via JWT) ---
        static let wishlistEndpoint = "\(customApiBaseURL)/wishlist" // GET, DELETE
        static let wishlistAddItemEndpoint = "\(customApiBaseURL)/wishlist/item/add" // POST
        static let wishlistRemoveItemEndpoint = "\(customApiBaseURL)/wishlist/item/remove" // POST
        
        // --- Adressen (User-gebunden, via JWT) ---
        static let userAddressesEndpoint = "\(customApiBaseURL)/user/addresses" // GET, POST (update)
        
        // --- Bestelldetails (Öffentlich, mit Order Key) ---
        static let orderDetailsEndpoint = "\(customApiBaseURL)/order-details" // GET
        
        // --- Checkout-Prozess ---
        // Stellt den Warenkorb für den Checkout bereit und gibt einen Token zurück.
        static let stageCartForCheckoutEndpoint = "\(customApiBaseURL)/stage-cart-for-population" // POST
    }
}
