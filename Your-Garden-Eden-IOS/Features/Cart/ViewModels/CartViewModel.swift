import Foundation
import Combine

@MainActor
class CartViewModel: ObservableObject {
    
    // MARK: - Published Properties for the View
    @Published var items: [Item] = []
    @Published var totals: Totals?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let cartManager = CartAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("🛒 CartViewModel initialized.")
        // Wir abonnieren die Änderungen vom CartAPIManager.
        
        cartManager.$currentCart
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cart in
                self?.items = cart?.safeItems ?? []
                // --- HIER IST DIE KORREKTUR ---
                // Da 'self' wegen [weak self] optional ist, müssen wir auch hier
                // optionales Chaining verwenden.
                self?.totals = cart?.totals
            }
            .store(in: &cancellables)
            
        cartManager.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
            
        cartManager.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods for View Interaction
    
    /// Aktualisiert die Menge eines Artikels im Warenkorb.
    func updateQuantity(for item: Item, newQuantity: Int) {
        guard item.quantity != newQuantity else { return }
        
        isLoading = true
        Task {
            do {
                try await cartManager.updateItemQuantity(itemKey: item.key, quantity: newQuantity)
            } catch {
                print("🔴 CartViewModel: Failed to update quantity - \(error.localizedDescription)")
            }
        }
    }
    
    /// Entfernt einen Artikel komplett aus dem Warenkorb.
    func removeItem(_ item: Item) {
        isLoading = true
        Task {
            do {
                try await cartManager.removeItem(itemKey: item.key)
            } catch {
                print("🔴 CartViewModel: Failed to remove item - \(error.localizedDescription)")
            }
        }
    }
    
    /// Löst eine manuelle Aktualisierung des Warenkorbs aus.
    func refreshCart() async {
        _ = await cartManager.getCart()
    }
}
