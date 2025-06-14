// Path: Your-Garden-Eden-IOS/Core/Service/CartAPIManager.swift

import Foundation

@MainActor
final class CartAPIManager: ObservableObject {
    struct State {
        var items: [Item] = []
        var totals: Totals? = nil
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var updatingItemKey: String? = nil
        var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
    }

    @Published private(set) var state = State()

    static let shared = CartAPIManager()
    
    private let session: URLSession

    private init() {
        self.session = URLSession(configuration: .default)
        print("✅ CartAPIManager initialized.")
    }

    func initializeAndFetchCart() async {
        await getCart(showLoadingIndicator: true)
    }

    // MARK: - Public Cart Actions

    func getCart(showLoadingIndicator: Bool = false) async {
        await performCartAction(isLoading: showLoadingIndicator) {
            try await self.performCartRequest(path: "cart", httpMethod: "GET")
        }
    }

    func addItem(productId: Int, quantity: Int, variationId: Int? = nil) async {
        await performCartAction(isLoading: true) {
            var body: [String: Any] = ["id": productId, "quantity": quantity]
            if let variationId = variationId, variationId > 0 {
                body["id"] = variationId
            }
            return try await self.performCartRequest(path: "cart/add-item", httpMethod: "POST", body: body)
        }
    }

    func updateQuantity(for item: Item, newQuantity: Int) async {
        await performCartAction(updatingItemKey: item.key) {
            try await self.performCartRequest(path: "cart/items/\(item.key)", httpMethod: "PUT", body: ["quantity": newQuantity])
        }
    }

    func removeItem(_ item: Item) async {
        await performCartAction(updatingItemKey: item.key) {
            try await self.performCartRequest(path: "cart/items/\(item.key)", httpMethod: "DELETE")
        }
    }
    
    // MARK: - Private Core Logic
    
    private func performCartAction(
        isLoading: Bool = false,
        updatingItemKey: String? = nil,
        _ action: @escaping () async throws -> WooCommerceStoreCart?
    ) async {
        var currentState = self.state
        currentState.isLoading = isLoading
        currentState.updatingItemKey = updatingItemKey
        currentState.errorMessage = nil
        self.state = currentState

        do {
            if let newCart = try await action() {
                currentState.items = newCart.safeItems
                currentState.totals = newCart.totals
            }
        } catch let error as WooCommerceAPIError {
            currentState.errorMessage = error.localizedDescriptionForUser
            print("🔴 CartAPIManager Error: \(error.localizedDescription)")
        } catch {
            currentState.errorMessage = error.localizedDescription
            print("🔴 CartAPIManager Error: \(error.localizedDescription)")
        }
        
        currentState.isLoading = false
        currentState.updatingItemKey = nil
        self.state = currentState
    }
    
    @discardableResult
    private func performCartRequest(path: String, httpMethod: String, body: [String: Any]? = nil) async throws -> WooCommerceStoreCart? {
        guard let url = URL(string: AppConfig.WooCommerce.storeApiBaseURL + path) else { throw WooCommerceAPIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let cartToken = try? KeychainHelper.getCartToken() {
             request.setValue(cartToken, forHTTPHeaderField: "Nonce")
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw WooCommerceAPIError.underlying(NSError(domain: "network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])) }
        
        if let nonce = httpResponse.value(forHTTPHeaderField: "Nonce") {
            try? KeychainHelper.saveCartToken(nonce)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(WooCommerceStoreErrorResponse.self, from: data)
            throw WooCommerceAPIError.serverError(statusCode: httpResponse.statusCode, message: errorResponse?.message, errorCode: errorResponse?.code)
        }
        
        if data.isEmpty || httpMethod == "DELETE" {
            // After deleting, we must re-fetch the cart to get the updated state
            return try await performCartRequest(path: "cart", httpMethod: "GET")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(WooCommerceStoreCart.self, from: data)
    }
}
