// YGE-IOS-App/Features/Products/ProductListViewModel.swift
import SwiftUI // oder Foundation, wenn keine UI-Elemente direkt hier sind

@MainActor
class ProductListViewModel: ObservableObject {
    @Published var products: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    private(set) var currentCategoryId: Int? // private(set), damit es nur intern geändert wird

    // Methode zum Abrufen von Produkten
    func fetchProducts(categoryId: Int, initialLoad: Bool = true, perPage: Int = 10) {
        if !initialLoad && currentPage > totalPages && totalPages != 0 { // totalPages != 0 verhindert Endlosschleife bei initial leerem Ergebnis
             isLoadingMore = false // Sicherstellen, dass der Ladezustand zurückgesetzt wird
             return
        }

        if initialLoad {
            self.isLoading = true
            self.currentPage = 1
            self.products = []
            self.currentCategoryId = categoryId // Kategorie-ID speichern
            self.totalPages = 1 // Zurücksetzen, bis neue Infos kommen
        } else {
            self.isLoadingMore = true
        }
        self.errorMessage = nil

        Task {
            do {
                // Korrekter Aufruf mit perPage vor page
                let container = try await WooCommerceAPIManager.shared.getProducts(
                    categoryId: categoryId,
                    perPage: perPage,      // perPage
                    page: self.currentPage // page
                    // Weitere Parameter wie orderBy, order bei Bedarf hier übergeben
                )
                
                if initialLoad {
                    self.products = container.products
                } else {
                    self.products.append(contentsOf: container.products)
                }
                self.totalPages = container.totalPages
                
                // Seitenzählung nur erhöhen, wenn erfolgreich geladen und es mehr Seiten gibt
                if self.currentPage < self.totalPages {
                    self.currentPage += 1
                }

            } catch let error as WooCommerceAPIError {
                self.errorMessage = "Fehler beim Laden der Produkte: \(error.localizedDescription)"
                print("ProductListViewModel Error: \(error)")
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
                print("ProductListViewModel Unknown Error: \(error)")
            }
            
            if initialLoad {
                self.isLoading = false
            } else {
                self.isLoadingMore = false
            }
        }
    }
    
    // Methode zum Nachladen von Inhalten
    func loadMoreContentIfNeeded(currentItem product: WooCommerceProduct?) {
        guard let currentCatId = self.currentCategoryId else { return } // Nur laden, wenn eine Kategorie gesetzt ist

        // Wenn product nil ist, könnte es ein Aufruf von einem leeren Listen-Footer sein
        if product == nil {
            if !isLoadingMore && currentPage <= totalPages {
                fetchProducts(categoryId: currentCatId, initialLoad: false)
            }
            return
        }
        
        // Finde den Index des aktuellen Produkts
        guard let productIndex = products.firstIndex(where: { $0.id == product?.id }) else {
            return
        }

        // Schwelle zum Nachladen (z.B. wenn die letzten 5 Elemente erreicht sind)
        let thresholdIndex = products.index(products.endIndex, offsetBy: -5)
        if productIndex >= thresholdIndex && !isLoadingMore && currentPage <= totalPages {
            fetchProducts(categoryId: currentCatId, initialLoad: false)
        }
    }
}
