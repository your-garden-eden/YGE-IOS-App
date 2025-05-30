// Core/Utils/Manager/CartAPIManager.swift
import Foundation
import Combine

@MainActor
class CartAPIManager: ObservableObject {
    // MARK: - Singleton Instance
    static let shared = CartAPIManager()

    // MARK: - Published Properties
    @Published var currentCart: WooCommerceStoreCart?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private var cartToken: String?
    private var nonce: String?
    private var cancellables = Set<AnyCancellable>()
    private let storeApiBaseURL = AppConfig.WooCommerce.storeApiBaseURL // Annahme: AppConfig ist zugänglich

    // MARK: - Initializer (private für Singleton)
    private init() {
        print("CartAPIManager initialized (Singleton).")
        loadCartTokenFromKeychain()
        // Weitere Initialisierungen hier, falls nötig
    }

    // MARK: - Token Management
    private func loadCartTokenFromKeychain() {
        do {
            self.cartToken = try KeychainHelper.getCartToken()
            if let token = self.cartToken { print("CartAPIManager: Loaded token: \(token.prefix(10))...") }
            else { print("CartAPIManager: No token in Keychain.") }
        } catch { print("CartAPIManager: Error loading token: \(error.localizedDescription)") }
    }

    private func saveCartTokenToKeychain(_ token: String) {
        do {
            try KeychainHelper.saveCartToken(token)
            self.cartToken = token
            print("CartAPIManager: Saved token: \(token.prefix(10))...")
        } catch {
            self.errorMessage = "Error saving cart session: \(error.localizedDescription)"
            print("CartAPIManager: Error saving token: \(error.localizedDescription)")
        }
    }

    private func deleteCartTokenFromKeychain() {
        do {
            try KeychainHelper.deleteCartToken()
            self.cartToken = nil
            print("CartAPIManager: Deleted token from Keychain.")
        } catch {
            self.errorMessage = "Error deleting cart session: \(error.localizedDescription)"
            print("CartAPIManager: Error deleting token: \(error.localizedDescription)")
        }
    }
    
    func clearLocalCartInfoAndReloadFromServer() async { // Behalte deine Implementierung
        print("CartAPIManager: Clearing local cart info.")
        currentCart = nil
        deleteCartTokenFromKeychain()
        self.nonce = nil
    }


    // MARK: - API Call Helper
    private func makeStoreAPIRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        // ... (deine bestehende Implementierung von makeStoreAPIRequest)
        guard let url = URL(string: "\(storeApiBaseURL)\(endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint)") else {
            throw WooCommerceAPIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = self.cartToken { request.setValue(token, forHTTPHeaderField: "Cart-Token") }
        if let nonceValue = self.nonce { request.setValue(nonceValue, forHTTPHeaderField: "X-WC-Store-API-Nonce") }
        if let bodyData = body { request.httpBody = bodyData }
        print("CartAPIManager [Request]: \(method) \(url.path)")
        let data: Data; let response: URLResponse
        do { (data, response) = try await URLSession.shared.data(for: request) }
        catch { print("CartAPIManager [Network Error]: \(error.localizedDescription) for \(url.path)"); throw WooCommerceAPIError.networkError(error) }
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.underlying(URLError(.badServerResponse)) }
        print("CartAPIManager [Response Status]: \(httpResponse.statusCode) for \(url.path)")
        if let newCartTokenHeader = httpResponse.value(forHTTPHeaderField: "Cart-Token"), self.cartToken != newCartTokenHeader {
            print("CartAPIManager: Received new/updated cart token. Saving."); saveCartTokenToKeychain(newCartTokenHeader)
        }
        if let newNonceHeader = httpResponse.value(forHTTPHeaderField: "X-WC-Store-API-Nonce"), self.nonce != newNonceHeader {
            print("CartAPIManager: Received new/updated nonce. Updating in memory."); self.nonce = newNonceHeader
        }
        if !(200...299).contains(httpResponse.statusCode) {
            do {
                let errorResponse = try JSONDecoder().decode(WooCommerceErrorResponse.self, from: data)
                print("CartAPIManager: Server Error (Parsed JSON): Code [\(errorResponse.code ?? "N/A")] Message [\(errorResponse.message ?? "N/A")] for \(url.path)")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorResponse.message, errorCode: errorResponse.code)
            } catch {
                let rawBody = String(data: data, encoding: .utf8)?.prefix(200) ?? "Unreadable error body"
                print("CartAPIManager: Server Error (Unparsed JSON, Status \(httpResponse.statusCode)): \(rawBody) for \(url.path)")
                throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: "Serverfehler, Details konnten nicht verarbeitet werden.", errorCode: nil)
            }
        }
        if httpResponse.statusCode == 204 { if T.self == Void.self { return () as! T } else { throw WooCommerceAPIError.noData } }
        if data.isEmpty { if T.self == Void.self { return () as! T } else { throw WooCommerceAPIError.noData } }
        do { return try JSONDecoder().decode(T.self, from: data) }
        catch let decodingError {
            let rawBody = String(data: data, encoding: .utf8)?.prefix(500) ?? "Unreadable body"
            print("CartAPIManager: Decoding Error for type \(T.self): \(decodingError.localizedDescription). Body: \(rawBody) for \(url.path)")
            throw WooCommerceAPIError.decodingError(decodingError)
        }
    }

    // MARK: - Initial Load Trigger
    func ensureTokensAndCartLoaded() async {
        // ... (deine bestehende Implementierung)
        if isLoading { print("CartAPIManager: Already loading cart."); return }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        print("CartAPIManager: Ensuring tokens and cart are loaded...")
        await getCart() // Rufe getCart auf, um den Warenkorb zu laden
    }

    // MARK: - Cart Operations
    func getCart() async {
        // ... (deine bestehende Implementierung von getCart)
        if !isLoading { isLoading = true; errorMessage = nil; do { isLoading = false } }
        print("CartAPIManager: Attempting to get cart...")
        do {
            let cartObject: WooCommerceStoreCart = try await makeStoreAPIRequest(endpoint: "cart", method: "GET", body: nil)
            self.currentCart = cartObject
            print("CartAPIManager: Fetched cart. Items: \(cartObject.itemsCount)")
        } catch let error as WooCommerceAPIError {
            self.errorMessage = error.localizedDescription
            print("CartAPIManager: API Error fetching cart: \(error.localizedDescription)")
            if case .serverError(_, _, let errorCode) = error, errorCode == "wc/store/cart/invalid-cart-token" { deleteCartTokenFromKeychain(); self.nonce = nil; self.currentCart = nil }
            else if case .serverError(let sc, _, let ec) = error, (ec == "wc/store/cart/empty" || ec == "woocommerce_rest_cart_empty") && sc == 404 { self.currentCart = nil; self.errorMessage = nil }
        } catch {
            self.errorMessage = "Unexpected error fetching cart."
            print("CartAPIManager: Unexpected error fetching cart: \(error.localizedDescription)")
        }
    }
    
    // ... (deine bestehenden Implementierungen für addItem, updateItemQuantity, removeItem, clearCart)
    // Beispiel addItem:
    func addItem(productId: Int, quantity: Int = 1, variation: [WooCommerceStoreCartItemVariationAttribute]? = nil) async throws {
        isLoading = true; errorMessage = nil; defer { isLoading = false }
        print("CartAPIManager: Adding item (ID: \(productId), Qty: \(quantity))")
        struct AddToCartBody: Codable { let id: Int; let quantity: Int; let variation: [WooCommerceStoreCartItemVariationAttribute]? }
        let bodyPayload = AddToCartBody(id: productId, quantity: quantity, variation: variation)
        let requestBody: Data = try JSONEncoder().encode(bodyPayload)
        do {
            let updatedCart: WooCommerceStoreCart = try await makeStoreAPIRequest(endpoint: "cart/add-item", method: "POST", body: requestBody)
            self.currentCart = updatedCart
            print("CartAPIManager: Item added. Count: \(updatedCart.itemsCount)")
        } catch {
            self.errorMessage = (error as? LocalizedError)?.localizedDescription ?? "Failed to add item."
            print("CartAPIManager: Error adding item: \(error.localizedDescription)")
            throw error
        }
    }
    // (Füge hier die anderen Warenkorb-Methoden ein, falls sie nicht schon da waren)
    func updateItemQuantity(itemKey: String, quantity: Int) async throws { /* ... */ }
    func removeItem(itemKey: String) async throws { /* ... */ }
    func clearCart() async throws { /* ... */ }
}
