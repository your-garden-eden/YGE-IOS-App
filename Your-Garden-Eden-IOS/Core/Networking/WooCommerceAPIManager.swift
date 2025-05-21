import Foundation

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()
    private let proxyService = FirebaseProxyService.shared

    private init() {}

    // --- PRODUCTS ---
    // func getProducts(categoryId: Int?, perPage: Int, page: Int, completion: @escaping (Result<[WooCommerceProduct], Error>) -> Void) {
    //     let functionName = "getProducts" // Name deiner Cloud Function
    //     let requestData = ["categoryId": categoryId, "perPage": perPage, "page": page] // Beispiel
    //     proxyService.callFunction(functionName: functionName, data: requestData) { (result: Result<[WooCommerceProduct], FirebaseProxyService.ProxyServiceError>) in
    //         // Konvertiere ProxyServiceError ggf. in einen spezifischeren Fehler oder gib es direkt weiter
    //         completion(result.mapError { $0 as Error })
    //     }
    // }

    // func getProductById(productId: Int, completion: @escaping (Result<WooCommerceProduct, Error>) -> Void) { ... }
    
    // --- CATEGORIES ---
    // func getCategories(completion: @escaping (Result<[WooCommerceCategory], Error>) -> Void) { ... }

    // --- CART (Store API) ---
    // func getCart(completion: @escaping (Result<WooCommerceStoreCart, Error>) -> Void) { ... }
    // func addItemToCart(productId: Int, quantity: Int, variationId: Int?, completion: @escaping (Result<WooCommerceStoreCart, Error>) -> Void) { ... }
    // ... weitere Warenkorb-Funktionen

    // --- ORDERS ---
    // func createOrder(cart: WooCommerceStoreCart, customerDetails: ..., completion: @escaping (Result<WooCommerceOrder, Error>) -> Void) { ... }
    // (Benötigt WooCommerceOrder Modell)
}
