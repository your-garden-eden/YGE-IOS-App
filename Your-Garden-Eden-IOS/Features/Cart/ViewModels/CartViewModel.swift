// Features/Cart/ViewModels/CartViewModel.swift
import SwiftUI
import Combine

@MainActor
class CartViewModel: ObservableObject {
    // Beobachte den CartAPIManager als @ObservedObject, da er ein Singleton ist
    // und seine Änderungen die UI des CartViewModel (und damit der CartView) beeinflussen.
    @ObservedObject var cartAPIManager = CartAPIManager.shared

    // Computed property für einfachen Zugriff auf Items
    var cartItems: [WooCommerceStoreCartItem] {
        cartAPIManager.currentCart?.items ?? []
    }

    var cartTotals: WooCommerceStoreCartTotals? {
        cartAPIManager.currentCart?.totals
    }

    var currencySymbol: String {
        // Stelle sicher, dass AppConfig.WooCommerce.defaultCurrencySymbol existiert
        cartAPIManager.currentCart?.totals.currencySymbol ?? AppConfig.WooCommerce.defaultCurrencySymbol
    }
    
    // Wird benötigt, um den @StateObject in der CartView zu initialisieren, auch wenn er nichts tut.
    // Die Hauptlogik läuft über den cartAPIManager oder direkte Funktionsaufrufe.
    init() {
        print("CartViewModel initialized.")
        // Wir stellen sicher, dass der Warenkorb geladen wird, wenn der CartAPIManager initialisiert wird
        // oder wenn die App startet und der CartAPIManager im Environment ist.
        // Ein expliziter Aufruf hier kann helfen, wenn die CartView direkt aufgerufen wird
        // und der Warenkorb möglicherweise noch nicht geladen wurde.
        if cartAPIManager.currentCart == nil && !cartAPIManager.isLoading {
            Task {
                print("CartViewModel: Initializing and ensuring cart is loaded via CartAPIManager.")
                 cartAPIManager.ensureTokensAndCartLoaded()
            }
        }
    }

    func updateQuantity(for itemKey: String, newQuantity: Int) {
        guard newQuantity > 0 else {
            removeItem(itemKey: itemKey)
            return
        }
        // Die Ladezustände und Fehlermeldungen werden vom cartAPIManager gehandhabt
        // und können direkt in der View beobachtet werden.
        Task {
            do {
                try await cartAPIManager.updateItemQuantity(itemKey: itemKey, quantity: newQuantity)
                print("CartViewModel: Quantity update for \(itemKey) to \(newQuantity) requested.")
            } catch {
                print("CartViewModel: Error updating quantity for item \(itemKey): \(error.localizedDescription)")
                // cartAPIManager.errorMessage wird bereits gesetzt
            }
        }
    }

    func removeItem(itemKey: String) {
        Task {
            do {
                try await cartAPIManager.removeItem(itemKey: itemKey)
                print("CartViewModel: Remove item \(itemKey) requested.")
            } catch {
                print("CartViewModel: Error removing item \(itemKey): \(error.localizedDescription)")
            }
        }
    }

    func clearCart() {
        Task {
            do {
                try await cartAPIManager.clearCart()
                print("CartViewModel: Clear cart requested.")
            } catch {
                 print("CartViewModel: Error clearing cart: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshCart() async {
        print("CartViewModel: Refresh cart requested.")
        // isLoading und errorMessage werden vom cartAPIManager gehandhabt.
        await cartAPIManager.getCart()
    }
}
