// Dateiname: CartViewModel.swift

import Foundation
import Combine

@MainActor
class CartViewModel: ObservableObject {
    
    @Published var items: [Item] = []
    @Published var totals: Totals?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let cartManager = CartAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("🛒 CartViewModel initialized.")
        
        // KORREKTUR: Wir lauschen jetzt auf die 'items'-Eigenschaft des CartAPIManager.
        cartManager.$items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
            
        // KORREKTUR: Wir lauschen jetzt auf die 'totals'-Eigenschaft.
        cartManager.$totals
            .receive(on: DispatchQueue.main)
            .assign(to: \.totals, on: self)
            .store(in: &cancellables)
            
        // Diese bleiben unverändert, da die Properties im CartAPIManager noch existieren.
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
    
    func updateQuantity(for item: Item, newQuantity: Int) {
        guard item.quantity != newQuantity else { return }
        
        Task {
            // KORREKTUR: Ruft jetzt die korrekte Funktion im CartAPIManager auf.
            await cartManager.updateQuantity(for: item, newQuantity: newQuantity)
        }
    }
    
    func removeItem(_ item: Item) {
        Task {
            // KORREKTUR: Ruft jetzt die korrekte Funktion mit dem korrekten Parameter auf.
            await cartManager.removeItem(item)
        }
    }
    
    func refreshCart() async {
        await cartManager.getCart()
    }
}
