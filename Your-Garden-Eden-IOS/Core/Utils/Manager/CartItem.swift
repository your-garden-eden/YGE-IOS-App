import Foundation
import Combine

// Definiert, wie ein einzelner Artikel im Warenkorb aussieht.
struct CartItem: Identifiable, Codable, Equatable {
    let id: Int
    let productId: Int
    let productName: String
    var quantity: Int
    let price: String
    let variationId: Int?
    let variationDescription: String?
    let imageUrl: String?
}

// Der globale Manager, der den Warenkorb-Zustand für die gesamte App verwaltet.
@MainActor
class CartManager: ObservableObject {
    
    static let shared = CartManager()
    
    @Published private(set) var items: [CartItem] = []
    
    private init() {}
    
    /// Fügt ein Produkt (oder eine Variation) zum Warenkorb hinzu.
    func addToCart(product: WooCommerceProduct, variation: WooCommerceProductVariation?, quantity: Int) {
        
        let itemId = variation?.id ?? product.id
        
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items[index].quantity += quantity
            print("CartManager: Increased quantity for item \(itemId) to \(items[index].quantity).")
        } else {
            // KORREKTUR: Die unnötige `guard let`-Prüfung wurde entfernt, da `attr.name`
            // ein garantierter String ist. Wir verwenden stattdessen eine einfache `map`-Operation.
            let variationDesc = variation?.attributes.map { attr in
                return "\(attr.name): \(attr.option)"
            }.joined(separator: ", ")

            let newItem = CartItem(
                id: itemId,
                productId: product.id,
                productName: product.name,
                quantity: quantity,
                price: variation?.price ?? product.price,
                variationId: variation?.id,
                variationDescription: variationDesc,
                imageUrl: (variation?.image ?? product.images.first)?.src
            )
            items.append(newItem)
            print("CartManager: Added new item \(itemId) to cart.")
        }
    }
    
    /// Entfernt einen Artikel vollständig aus dem Warenkorb.
    func removeFromCart(itemId: Int) {
        items.removeAll { $0.id == itemId }
    }
    
    /// Aktualisiert die Menge eines bestimmten Artikels.
    func updateQuantity(itemId: Int, newQuantity: Int) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            if newQuantity > 0 {
                items[index].quantity = newQuantity
            } else {
                removeFromCart(itemId: itemId)
            }
        }
    }
    
    // Berechnete Eigenschaften für die UI
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        items.reduce(0) { total, item in
            let priceString = item.price.replacingOccurrences(of: ",", with: ".")
            let priceValue = Double(priceString) ?? 0.0
            return total + (priceValue * Double(item.quantity))
        }
    }
}
