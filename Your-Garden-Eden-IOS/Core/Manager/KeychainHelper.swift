// YGE-IOS-App/Core/Managers/CartAPIManager.swift
import Foundation
import SwiftUI // Für @MainActor und ObservableObject

// --- Keychain Helper (PLATZHALTER) ---
class KeychainHelper {
    static let cartTokenKey = "com.your-garden-eden.cartToken" // Passe dies an deinen Bundle Identifier an

    static func save(token: String) {
        UserDefaults.standard.set(token, forKey: cartTokenKey)
        print("[KeychainHelper - DEMO] Token saved (UserDefaults): \(token)")
    }
    static func loadToken() -> String? {
        let token = UserDefaults.standard.string(forKey: cartTokenKey)
        print("[KeychainHelper - DEMO] Token loaded (UserDefaults): \(token ?? "nil")")
        return token
    }
    static func deleteToken() {
        UserDefaults.standard.removeObject(forKey: cartTokenKey)
        print("[KeychainHelper - DEMO] Token deleted (UserDefaults)")
    }
}

// --- Cart API Manager ---
@MainActor
class CartAPIManager: ObservableObject {
    static let shared = CartAPIManager()

    private let storeApiBaseURL = AppConfig.WooCommerce.storeApiBaseURL
    private let session: URLSession

    @Published private(set) var cartToken: String?
    @Published private(set) var nonce: String?

    @Published var currentCart: WooCommerceStoreCart?
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private var tokenFetchTask: Task<Void, Error>?

    private init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
        self.cartToken = KeychainHelper.loadToken()
        print("CartAPIManager initialized. Cart Token: \(self.cartToken ?? "nil")")
        Task {
            await loadInitialCartOrFetchTokens()
        }
    }

    // MARK: - Token Management
    private func updateTokensFromResponse(_ httpResponse: HTTPURLResponse) {
        if let newNonce = httpResponse.value(forHTTPHeaderField: "X-WC-Store-API-Nonce")?.trimmingCharacters(in: .whitespacesAndNewlines), !newNonce.isEmpty {
            if self.nonce != newNonce { self.nonce = newNonce; print("CartAPIManager: Nonce updated: \(newNonce)") }
        }
        if let newCartToken = httpResponse.value(forHTTPHeaderField: "Cart-Token")?.trimmingCharacters(in: .whitespacesAndNewlines), !newCartToken.isEmpty {
            if self.cartToken != newCartToken { self.cartToken = newCartToken; KeychainHelper.save(token: newCartToken); print("CartAPIManager: Cart Token updated: \(newCartToken)") }
        } else if httpResponse.url?.absoluteString.contains("/cart") == true && httpResponse.value(forHTTPHeaderField: "Cart-Token") == nil && self.cartToken != nil {
            print("CartAPIManager: Cart-Token nicht in Antwort von /cart gefunden. Alter Token: \(self.cartToken!). Nonce: \(self.nonce ?? "nil")")
        }
    }

    private func getHeaders() -> [String: String] {
        var headers: [String: String] = ["Content-Type": "application/json", "Accept": "application/json"]
        if let token = self.cartToken { headers["Cart-Token"] = token }
        if let currentNonce = self.nonce { headers["X-WC-Store-API-Nonce"] = currentNonce }
        return headers
    }
    
    private func fetchAndSetInitialTokens() async throws {
        print("CartAPIManager: Fetching initial tokens (and cart)...")
        guard let url = URL(string: storeApiBaseURL + "/cart") else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid response in fetchAndSetInitialTokens"]))
        }
        updateTokensFromResponse(httpResponse)

        if (200...299).contains(httpResponse.statusCode) {
            do {
                let decodedCart = try JSONDecoder().decode(WooCommerceStoreCart.self, from: data)
                self.currentCart = decodedCart
                print("CartAPIManager: Initial tokens/cart fetched successfully.")
            } catch {
                var errorResponseCode: String?
                if let decodedError = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                    errorResponseCode = decodedError.code
                }
                if errorResponseCode == "woocommerce_rest_cart_empty" || httpResponse.statusCode == 404 || (data.isEmpty && httpResponse.statusCode == 200) {
                    self.currentCart = nil
                    print("CartAPIManager: Initial tokens fetched, cart is empty.")
                } else {
                    print("CartAPIManager: Decoding error for initial cart data. Error: \(error)")
                    throw WooCommerceAPIError.decodingError(error)
                }
            }
        } else {
            var msg = "Failed to fetch initial tokens/cart."
            var errCode: String?
            if let errorDetails = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                msg = errorDetails.message ?? msg
                errCode = errorDetails.code
            }
            print("CartAPIManager: Server error fetching initial tokens/cart. Status: \(httpResponse.statusCode). Message: \(msg)")
            if self.nonce == nil && self.cartToken == nil {
                 throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: msg, errorCode: errCode)
            }
        }
        if self.cartToken == nil && self.nonce == nil {
            print("CartAPIManager: CRITICAL - Failed to obtain Cart-Token or Nonce after initial fetch.")
            throw WooCommerceAPIError.authenticationRequired
        }
    }

    private func ensureTokensAndCartLoaded() async throws {
        if let existingTask = tokenFetchTask {
            try await existingTask.value; return
        }
        let taskToRun: Task<Void, Error>?
        if cartToken != nil && currentCart == nil {
            taskToRun = Task { try await self.getCart() }
        } else if cartToken == nil {
            taskToRun = Task { try await self.fetchAndSetInitialTokens() }
        } else {
            taskToRun = nil
        }
        if let actualTask = taskToRun {
            self.tokenFetchTask = actualTask
            do { try await actualTask.value } catch { self.tokenFetchTask = nil; throw error }
            self.tokenFetchTask = nil
        }
    }
    
    func loadInitialCartOrFetchTokens() async {
        self.isLoading = true; self.error = nil
        do {
            try await ensureTokensAndCartLoaded()
            print("CartAPIManager: Initial cart/token load sequence completed.")
        } catch let e {
            print("CartAPIManager: Error during loadInitialCartOrFetchTokens: \(e.localizedDescription)")
            self.error = e
            if let apiError = e as? WooCommerceAPIError {
                 if case .serverError(let statusCode, _, let errorCode) = apiError,
                    (statusCode == 401 || statusCode == 403 || errorCode == "woocommerce_rest_cart_token_invalid" || errorCode == "woocommerce_rest_nonce_invalid") {
                    clearLocalCartInfo()
                 } else if case .authenticationRequired = apiError {
                    clearLocalCartInfo()
                 }
            }
        }
        self.isLoading = false
    }

    // MARK: - Public Cart Operations
    func getCart() async throws {
        _ = try await performCartRequest(method: "GET", endpoint: "/cart")
    }

    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async throws {
        let body: [String: Any] = ["id": variationId ?? productId, "quantity": quantity]
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/add-item", body: body)
    }

    func updateItemQuantity(itemKey: String, quantity: Int) async throws {
        if quantity <= 0 { try await removeItem(itemKey: itemKey); return }
        let body = ["key": itemKey, "quantity": quantity] as [String : Any]
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/update-item", body: body)
    }

    func removeItem(itemKey: String) async throws {
        let body = ["key": itemKey]
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/remove-item", body: body)
    }

    func clearCart() async throws {
        _ = try await performCartRequest(method: "DELETE", endpoint: "/cart/items")
    }
    
    func updateCustomer(billingAddress: WooCommerceStoreAddress, shippingAddress: WooCommerceStoreAddress?) async throws {
        // Explizite Typannotation für bodyDict, um Ambiguität zu vermeiden
        var bodyDict: [String: Any?] = [
            "billing_address": billingAddress.dictionaryRepresentation
        ]
        if let shipping = shippingAddress {
            bodyDict["shipping_address"] = shipping.dictionaryRepresentation
        }
        // Konvertiere [String: Any?] zu [String: Any] durch Entfernen der nil-Werte
        let finalBody: [String: Any] = bodyDict.compactMapValues { $0 }
        
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/update-customer", body: finalBody)
    }

    func getShippingRates() async throws -> [WooCommerceStoreShippingPackage]? {
        let responseData = try await performCartRequest(method: "GET", endpoint: "/cart/shipping-rates", returnsArbitraryData: true)
        if let data = responseData, !data.isEmpty {
            return try JSONDecoder().decode([WooCommerceStoreShippingPackage].self, from: data)
        } else if responseData?.isEmpty == true {
             return []
        }
        return nil
    }
    
    func selectShippingRate(packageId: String, rateId: String) async throws {
        let body = ["package_id": packageId, "rate_id": rateId]
        _ = try await performCartRequest(method: "POST", endpoint: "/cart/select-shipping-rate", body: body)
    }
    
    // MARK: - Private Request Performer
    private func performCartRequest(
        method: String, endpoint: String, body: [String: Any]? = nil, returnsArbitraryData: Bool = false
    ) async throws -> Data? {
        try await ensureTokensAndCartLoaded()
        guard let url = URL(string: storeApiBaseURL + endpoint) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = getHeaders()

        if let requestBody = body { // Umbenannt, um Konflikt mit outer 'body' zu vermeiden (obwohl nicht strikt nötig hier)
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        }
        
        print("CartAPIManager: \(method) \(url.absoluteString) | Token: \(self.cartToken != nil) | Nonce: \(self.nonce != nil)")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WooCommerceAPIError.networkError(NSError(domain: "CartAPIManager", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Invalid response in performCartRequest"]))
        }
        updateTokensFromResponse(httpResponse)

        if !(200...299).contains(httpResponse.statusCode) {
            var errorMessage: String?
            var errorCode: String?
            if let errorDetails = try? JSONDecoder().decode(WooCommerceErrorResponse.self, from: data) {
                errorMessage = errorDetails.message
                errorCode = errorDetails.code
            }
            print("CartAPIManager: Store API Error \(httpResponse.statusCode) | \(method) \(url.absoluteString) | Code: \(errorCode ?? "N/A") | Message: \(errorMessage ?? "N/A")")
            
            if httpResponse.statusCode == 403 || httpResponse.statusCode == 401 || errorCode == "woocommerce_rest_cart_token_invalid" || errorCode == "woocommerce_rest_nonce_invalid" {
                clearLocalCartInfo()
                throw WooCommerceAPIError.authenticationRequired
            }
            // HIER DIE KORREKTUR für "Missing argument for parameter 'errorCode'":
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage, errorCode: errorCode)
        }

        if returnsArbitraryData {
            return data
        } else {
            if data.isEmpty && (httpResponse.statusCode == 200 || httpResponse.statusCode == 204) {
                 self.currentCart = nil
                 print("CartAPIManager: Request successful, response empty. Cart set to nil/empty.")
                 return nil
            }
            do {
                let decodedCart = try JSONDecoder().decode(WooCommerceStoreCart.self, from: data)
                self.currentCart = decodedCart
                print("CartAPIManager: Request successful, cart updated.")
                return data
            } catch {
                print("CartAPIManager: Decoding error for FULL CART from \(url.absoluteString). Error: \(error)")
                throw WooCommerceAPIError.decodingError(error)
            }
        }
    }
    
    // MARK: - Token Invalidation & Reload
    func clearLocalCartInfoAndReloadFromServer() async {
        print("CartAPIManager: Clearing local cart info and reloading from server...")
        clearLocalCartInfo()
        await loadInitialCartOrFetchTokens()
    }
    
    private func clearLocalCartInfo() {
        self.cartToken = nil; self.nonce = nil
        // self.currentCart = nil // Kann hier oder erst bei fehlgeschlagenem Reload geleert werden
        KeychainHelper.deleteToken()
        print("CartAPIManager: Local cart token and nonce cleared.")
    }
}

// Erweiterung für WooCommerceStoreAddress (bleibt gleich)
extension WooCommerceStoreAddress {
    var dictionaryRepresentation: [String: Any?] {
        return [
            "first_name": firstName, "last_name": lastName, "company": company,
            "address_1": address1, "address_2": address2, "city": city,
            "state": state, "postcode": postcode, "country": country,
            "email": email, "phone": phone
        ]
    }
}
