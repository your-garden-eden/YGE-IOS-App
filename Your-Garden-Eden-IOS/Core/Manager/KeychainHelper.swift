//
//  KeychainHelper.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.05.25.
//


// YGE-IOS-App/Core/Managers/CartAPIManager.swift
import Foundation
import Combine // Für @Published und ObservableObject, falls du es in ViewModels nutzen willst

// Keychain Helper (vereinfacht, du solltest eine robuste Bibliothek oder eigenen Code verwenden)
// Dies ist nur ein Platzhalter!
class KeychainHelper {
    static let cartTokenKey = "com.yourgardenenen.cartToken"

    static func save(token: String) {
        UserDefaults.standard.set(token, forKey: cartTokenKey) // NUR FÜR DEMO, NICHT SICHER! ECHTEN KEYCHAIN NUTZEN!
        print("[KeychainHelper - DEMO] Token saved (UserDefaults): \(token)")
    }
    static func loadToken() -> String? {
        let token = UserDefaults.standard.string(forKey: cartTokenKey) // NUR FÜR DEMO
        print("[KeychainHelper - DEMO] Token loaded (UserDefaults): \(token ?? "nil")")
        return token
    }
    static func deleteToken() {
        UserDefaults.standard.removeObject(forKey: cartTokenKey) // NUR FÜR DEMO
        print("[KeychainHelper - DEMO] Token deleted (UserDefaults)")
    }
}


@MainActor // Um UI-Updates auf dem Main Actor sicherzustellen, wenn mit @Published gearbeitet wird
class CartAPIManager: ObservableObject {
    static let shared = CartAPIManager()

    private let storeApiBaseURL = AppConfig.WooCommerce.storeApiBaseURL
    private let session: URLSession

    // Zustand für Tokens
    @Published private(set) var cartToken: String?
    @Published private(set) var nonce: String? // X-WC-Store-API-Nonce

    // Zustand für den Warenkorb selbst
    @Published var currentCart: WooCommerceStoreCart?
    @Published var isLoading: Bool = false
    @Published var error: Error? // Allgemeiner Fehler für den Manager

    private var tokenFetchTask: Task<Void, Error>? // Um parallele Token-Fetches zu vermeiden

    private init() {
        let config = URLSessionConfiguration.default
        // Wichtig: Standardmäßig sendet URLSession keine Cookies. withCredentials: true in Angular
        // bedeutet, dass Cookies gesendet werden. Für die Store API und Nonces ist das oft relevant.
        // In Swift: config.httpCookieStorage = HTTPCookieStorage.shared
        // config.httpCookieAcceptPolicy = .always (oder .onlyFromMainDocumentDomain)
        self.session = URLSession(configuration: config)
        
        self.cartToken = KeychainHelper.loadToken()
        print("CartAPIManager initialized. Cart Token from Keychain: \(self.cartToken ?? "nil")")
        
        // Initialer Warenkorb laden oder Tokens holen, wenn kein Cart-Token vorhanden
        Task {
            await loadInitialCartOrFetchTokens()
        }
    }

    // MARK: - Token Management (analog zu Angular Service)

    private func updateTokensFromResponse(_ httpResponse: HTTPURLResponse) {
        if let newNonce = httpResponse.value(forHTTPHeaderField: "X-WC-Store-API-Nonce") {
            if self.nonce != newNonce {
                self.nonce = newNonce
                print("CartAPIManager: Nonce updated: \(newNonce)")
            }
        }
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "Cart-Token") {
            if self.cartToken != newCartToken {
                self.cartToken = newCartToken
                KeychainHelper.save(token: newCartToken) // In Keychain speichern
                print("CartAPIManager: Cart Token updated and saved: \(newCartToken)")
            }
        } else if httpResponse.url?.absoluteString.contains("/cart") == true {
            // Fall: Server sendet keinen Cart-Token mehr (z.B. nach User-Login/-Logout, Session-Wechsel)
            // In diesem Fall könnte es sein, dass der alte Token ungültig wurde.
            // Oder der Nonce ist jetzt der primäre Auth-Mechanismus für die nächste Anfrage.
            // Dein Angular-Code hat hier eine ähnliche Logik.
            // Wenn kein Cart-Token mehr kommt, aber ein Nonce, ist das ok für die nächste Anfrage.
            // Wenn beides fehlt NACH einer Aktion, ist das ein Problem.
            if httpResponse.value(forHTTPHeaderField: "Cart-Token") == nil && self.cartToken != nil {
                 print("CartAPIManager: Cart-Token wurde in der Antwort nicht gefunden. Alter Token: \(self.cartToken ?? "nil"). Nonce: \(self.nonce ?? "nil")")
                 // Hier könnte man den lokalen Token löschen, wenn der Server ihn explizit "entfernt"
                 // Aber nur, wenn klar ist, dass er ungültig ist und nicht nur temporär fehlt.
            }
        }
    }

    private func getHeaders() -> [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        if let token = self.cartToken {
            headers["Cart-Token"] = token
        }
        // Der Nonce wird für POST/PUT/DELETE benötigt, für GET nicht zwingend, schadet aber nicht.
        // Die Store API sendet den Nonce oft als Antwort auf einen GET /cart Request.
        if let currentNonce = self.nonce {
            headers["X-WC-Store-API-Nonce"] = currentNonce
        }
        return headers
    }
    
    private func fetchAndSetInitialTokens() async throws {
        // Diese Methode wird nur aufgerufen, wenn wir *gar keinen* Cart-Token haben.
        // Sie ist äquivalent zum initialen GET /cart, um einen Nonce und ggf. einen neuen Cart-Token zu bekommen.
        print("CartAPIManager: No Cart-Token found. Fetching initial tokens (Nonce and potentially new Cart-Token)...")
        guard let url = URL(string: storeApiBaseURL + "/cart") else {
            throw WooCommerceAPIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Keine spezifischen Header für den allerersten Request, es sei denn, du hast einen initialen Nonce woanders her.
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type during token fetch"]))
        }

        updateTokensFromResponse(httpResponse) // Nonce und ggf. Cart-Token setzen

        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            do {
                let decodedCart = try JSONDecoder().decode(WooCommerceStoreCart.self, from: data)
                self.currentCart = decodedCart
                print("CartAPIManager: Initial tokens fetched, cart data also received.")
            } catch {
                // Wenn der Cart leer ist, sendet WooCommerce manchmal keinen Body oder einen anderen Status.
                // Das ist ok, Hauptsache die Header (Nonce, Cart-Token) sind da.
                if httpResponse.statusCode == 404 && (try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data))?.code == "woocommerce_rest_cart_empty" {
                     self.currentCart = nil // Explizit auf nil setzen
                     print("CartAPIManager: Initial tokens fetched, cart is empty (as per API).")
                } else {
                    print("CartAPIManager: Decoding error for initial cart data after token fetch, but tokens might be set. Error: \(error)")
                    // Nicht als fatalen Fehler für Token-Fetch werten, wenn Header da sind.
                }
            }
        } else {
             print("CartAPIManager: Failed to fetch initial tokens. Status: \(httpResponse.statusCode)")
            // Hier könntest du einen spezifischeren Fehler werfen, wenn der Token-Fetch scheitert.
            // Aber updateTokensFromResponse hat vielleicht schon etwas aus den Headern geholt.
             if self.nonce == nil && self.cartToken == nil {
                 throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: "Failed to fetch initial tokens and cart.")
             }
        }

        if self.cartToken == nil && self.nonce == nil {
            print("CartAPIManager: CRITICAL - Failed to obtain Cart-Token or Nonce.")
            throw WooCommerceAPIError.authenticationRequired // Oder spezifischerer Fehler
        }
    }


    // Stellt sicher, dass Tokens vorhanden sind, bevor ein Request gemacht wird.
    // Lädt den Warenkorb, wenn noch kein Token da ist (holt Token und Nonce).
    private func ensureTokensAndCartLoaded() async throws {
        if tokenFetchTask != nil {
            print("CartAPIManager: Waiting for existing token fetch task to complete...")
            try await tokenFetchTask?.value
            return
        }
        
        // Wenn wir einen Cart-Token haben, aber der Cart noch nicht geladen wurde, laden.
        if cartToken != nil && currentCart == nil {
            print("CartAPIManager: Cart-Token exists, but cart data missing. Loading cart...")
            tokenFetchTask = Task {
                try await self.getCart() // Dies wird auch Tokens aus der Antwort aktualisieren
            }
        }
        // Wenn wir gar keinen Cart-Token haben, müssen wir initial Tokens holen.
        else if cartToken == nil {
            print("CartAPIManager: No Cart-Token. Initiating token fetch (which also loads cart)...")
            tokenFetchTask = Task {
                try await self.fetchAndSetInitialTokens()
            }
        }
        // Wenn Cart-Token und Cart-Daten da sind, ist alles gut.
        else {
            print("CartAPIManager: Cart-Token and cart data seem to be present.")
            return
        }

        do {
            try await tokenFetchTask?.value
        } finally {
            tokenFetchTask = nil
        }
    }
    
    // Wird bei App-Start und ggf. bei User-Wechsel aufgerufen
    func loadInitialCartOrFetchTokens() async {
        self.isLoading = true
        self.error = nil
        do {
            if self.cartToken != nil {
                print("CartAPIManager: Attempting to load initial cart using existing token.")
                try await getCart()
            } else {
                print("CartAPIManager: No existing cart token, fetching initial tokens (will also load cart).")
                try await fetchAndSetInitialTokens()
            }
        } catch let e {
            print("CartAPIManager: Error during initial cart/token load: \(e)")
            self.error = e
            // Bei bestimmten Fehlern (z.B. ungültiger Token) Token löschen und neu versuchen?
             if let apiError = e as? WooCommerceAPIError {
                if case .serverError(let statusCode, _) = apiError, statusCode == 403 || statusCode == 401 {
                    print("CartAPIManager: Invalid token detected during initial load. Clearing token.")
                    clearLocalCartInfo() // Löscht Token und Nonce
                    // Kein automatischer Neuversuch hier, um Schleifen zu vermeiden. User muss ggf. Aktion auslösen.
                }
            }
        }
        self.isLoading = false
    }


    // MARK: - Public Cart Operations

    func getCart() async throws {
        _ = try await performCartRequest(method: "GET", endpoint: "/cart")
    }

    func addItem(productId: Int, quantity: Int, variationId: Int? = nil /*, variationAttributes: TODO */) async throws {
        var body: [String: Any] = ["quantity": quantity]
        if let varId = variationId {
            body["id"] = varId // Bei Variationen ist 'id' die Variations-ID
        } else {
            body["id"] = productId // Bei einfachen Produkten die Produkt-ID
        }
        // TODO: variationAttributes Handling, falls benötigt
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/add-item", body: body)
    }

    func updateItemQuantity(itemKey: String, quantity: Int) async throws {
        if quantity <= 0 {
            try await removeItem(itemKey: itemKey)
            return
        }
        let body = ["key": itemKey, "quantity": quantity]
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/update-item", body: body)
    }

    func removeItem(itemKey: String) async throws {
        let body = ["key": itemKey]
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/remove-item", body: body)
    }

    func clearCart() async throws {
        _ = try await performCartRequest(method: "DELETE", endpoint: "/cart/items")
        // Die API gibt bei Erfolg einen leeren Warenkorb zurück.
        // Der performCartRequest sollte currentCart aktualisieren.
        // Wenn die API einen 204 No Content oder ähnliches ohne Body zurückgibt,
        // müssen wir currentCart hier manuell auf nil oder ein leeres Struct setzen.
        // Die Store API gibt bei DELETE /cart/items einen leeren Cart zurück (oder sollte es).
    }
    
    func updateCustomer(billingAddress: WooCommerceStoreAddress, shippingAddress: WooCommerceStoreAddress?) async throws {
        var body: [String: Any] = ["billing_address": billingAddress.dictionaryRepresentation]
        if let shipping = shippingAddress {
            body["shipping_address"] = shipping.dictionaryRepresentation
        }
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/update-customer", body: body)
    }

    func getShippingRates() async throws -> [WooCommerceStoreShippingPackage]? {
        let responseData = try await performCartRequest(method: "GET", endpoint: "/cart/shipping-rates", returnsArbitraryData: true)
        // Die API gibt direkt ein Array von Packages zurück, nicht das volle Cart-Objekt.
        if let data = responseData {
            return try JSONDecoder().decode([WooCommerceStoreShippingPackage].self, from: data)
        }
        return nil
    }

    func selectShippingRate(packageId: String, rateId: String) async throws {
        let body = ["package_id": packageId, "rate_id": rateId]
        // Diese Anfrage gibt das volle Cart-Objekt zurück
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/select-shipping-rate", body: body)
    }
    
    // Hilfsfunktion für Requests an die Store API (Warenkorb)
    private func performCartRequest(
        method: String,
        endpoint: String,
        body: [String: Any]? = nil,
        returnsArbitraryData: Bool = false // True, wenn Endpunkt nicht das volle Cart-Objekt zurückgibt
    ) async throws -> Data? { // Gibt optional rohe Daten zurück, falls benötigt

        try await ensureTokensAndCartLoaded() // Stellt sicher, dass wir Tokens haben (holt sie ggf.)

        guard let url = URL(string: storeApiBaseURL + endpoint) else {
            throw WooCommerceAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = getHeaders()

        if let bodyData = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        }
        
        print("CartAPIManager: Performing \(method) to \(url.absoluteString) with token: \(self.cartToken ?? "none"), nonce: \(self.nonce ?? "none")")
        // if let b = body { print("CartAPIManager: Body: \(b)") }


        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]))
        }

        updateTokensFromResponse(httpResponse) // Wichtig: Tokens aus JEDER Antwort aktualisieren

        if !(200...299).contains(httpResponse.statusCode) {
            var errorMessage: String?
            var errorCode: String?
            if let errorData = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                errorMessage = errorData.message
                errorCode = errorData.code
            }
            print("CartAPIManager: Store API Error \(httpResponse.statusCode) for \(url.absoluteString). Code: \(errorCode ?? "N/A"), Message: \(errorMessage ?? "N/A")")
            // Spezifische Fehlerbehandlung für ungültige Tokens/Nonces
            if httpResponse.statusCode == 403 || httpResponse.statusCode == 401 || errorCode == "woocommerce_rest_cart_token_invalid" || errorCode == "woocommerce_rest_nonce_invalid" {
                print("CartAPIManager: Invalid token or nonce detected. Clearing local tokens.")
                clearLocalCartInfo() // Löscht Cart-Token und Nonce
                // Wir werfen den Fehler weiter, damit die aufrufende Stelle reagieren kann (z.B. UI-Update)
                // Beim nächsten Aufruf wird ensureTokensAndCartLoaded versuchen, neue Tokens zu holen.
                throw WooCommerceAPIError.authenticationRequired 
            }
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage ?? "Store API Error")
        }

        if returnsArbitraryData { // Wenn die Methode spezielle Daten zurückgibt (z.B. nur Shipping Rates)
            return data
        } else { // Standard: Erwartet das volle WooCommerceStoreCart Objekt
            if data.isEmpty && (httpResponse.statusCode == 200 || httpResponse.statusCode == 204) {
                 // Z.B. clearCart könnte 200 OK mit leerem Body für einen leeren Cart zurückgeben.
                 // Oder eine andere Aktion, die keine Daten zurückgibt aber erfolgreich war.
                 self.currentCart = nil // Oder ein leeres Cart-Struct, je nach API-Definition
                 print("CartAPIManager: Request successful, response body empty. Cart set to nil/empty.")
                 return nil
            }
            do {
                let decodedCart = try JSONDecoder().decode(WooCommerceStoreCart.self, from: data)
                self.currentCart = decodedCart
                print("CartAPIManager: Request successful, cart updated.")
                return data // Auch hier die Daten zurückgeben, falls der Aufrufer sie braucht
            } catch {
                print("CartAPIManager: Decoding error for cart data from \(url.absoluteString): \(error)")
                // Wenn die Daten nicht dekodiert werden können, aber der Status 2xx war, ist das ein Problem.
                throw WooCommerceAPIError.decodingError(error)
            }
        }
    }
    
    // Wird aufgerufen, wenn der Benutzer sich ändert oder Tokens ungültig sind
    func clearLocalCartInfoAndReloadFromServer() async {
        print("CartAPIManager: Clearing local cart info and reloading from server (e.g., after user change).")
        clearLocalCartInfo()
        await loadInitialCartOrFetchTokens()
    }
    
    private func clearLocalCartInfo() {
        self.cartToken = nil
        self.nonce = nil
        self.currentCart = nil
        KeychainHelper.deleteToken()
        print("CartAPIManager: Local cart token, nonce, and cart data cleared.")
    }
}

// Erweiterung für WooCommerceStoreAddress, um es einfacher in ein Dictionary für JSON umzuwandeln
extension WooCommerceStoreAddress {
    var dictionaryRepresentation: [String: Any?] {
        return [
            "first_name": firstName, "last_name": lastName, "company": company,
            "address_1": address1, "address_2": address2, "city": city,
            "state": state, "postcode": postcode, "country": country,
            "email": email, "phone": phone
        ].filter { $0.value != nil } // Nur Felder mit Werten einbeziehen
    }
}