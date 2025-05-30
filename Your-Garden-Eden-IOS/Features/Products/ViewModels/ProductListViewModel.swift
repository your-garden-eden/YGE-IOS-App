// YGE-IOS-App/Features/Products/ProductListViewModel.swift
import SwiftUI

@MainActor
class ProductListViewModel: ObservableObject {
    @Published var products: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    private(set) var currentCategoryId: Int?

    // Methode zum Abrufen von Produkten
    func fetchProducts(categoryId: Int, initialLoad: Bool = true, perPage: Int = 10) {
        // Verhindere unnötiges Nachladen, wenn alle Seiten geladen wurden
        if !initialLoad && currentPage > totalPages && totalPages != 0 {
             print("ProductListViewModel: All pages loaded for category \(categoryId). Current: \(currentPage), Total: \(totalPages)")
             isLoadingMore = false
             return
        }
        // Verhindere gleichzeitiges initiales Laden und Nachladen für dieselbe Kategorie
        if (initialLoad && isLoading) || (!initialLoad && isLoadingMore) {
            print("ProductListViewModel: Already \(initialLoad ? "loading" : "loading more") for category \(categoryId). Aborting.")
            return
        }


        if initialLoad {
            self.isLoading = true
            self.currentPage = 1
            self.products = [] // Wichtig: Produkte leeren beim initialen Laden
            self.currentCategoryId = categoryId
            self.totalPages = 1 // Zurücksetzen, bis neue Infos kommen
            print("ProductListViewModel: Initial fetch for category \(categoryId), page \(self.currentPage).")
        } else {
            self.isLoadingMore = true
            print("ProductListViewModel: Fetching more for category \(categoryId), page \(self.currentPage). Current products: \(self.products.count)")
        }
        self.errorMessage = nil

        Task {
            defer {
                // Stelle sicher, dass Ladezustände immer korrekt zurückgesetzt werden
                Task { @MainActor in
                    if initialLoad {
                        self.isLoading = false
                    } else {
                        self.isLoadingMore = false
                    }
                }
            }
            
            do {
                let container = try await WooCommerceAPIManager.shared.getProducts(
                    categoryId: categoryId,
                    perPage: perPage,
                    page: self.currentPage
                )
                
                let newProducts = container.products
                print("ProductListViewModel: API returned \(newProducts.count) products for category \(categoryId), page \(self.currentPage). Total pages from API: \(container.totalPages)")

                if initialLoad {
                    self.products = newProducts
                    print("ProductListViewModel: Initial load. Assigned \(self.products.count) products.")
                } else {
                    let existingProductIDs = Set(self.products.map { $0.id })
                    let uniqueNewProducts = newProducts.filter { !existingProductIDs.contains($0.id) }
                    
                    if uniqueNewProducts.isEmpty && !newProducts.isEmpty {
                        print("ProductListViewModel: All \(newProducts.count) fetched products were duplicates.")
                    } else if !uniqueNewProducts.isEmpty {
                        self.products.append(contentsOf: uniqueNewProducts)
                        print("ProductListViewModel: Appended \(uniqueNewProducts.count) unique new products. Total now: \(self.products.count)")
                    } else {
                        print("ProductListViewModel: Fetched 0 new products or all were filtered out.")
                    }
                }
                
                self.totalPages = container.totalPages
                
                // Seitenzählung nur erhöhen, wenn erfolgreich geladen und es mehr Seiten gibt
                // und die aktuelle Seite nicht bereits die letzte oder eine ungültige Seite ist.
                if self.currentPage < self.totalPages {
                    self.currentPage += 1
                    print("ProductListViewModel: Incremented currentPage to \(self.currentPage). Total pages: \(self.totalPages)")
                } else if self.currentPage == self.totalPages {
                    print("ProductListViewModel: Reached last page (\(self.currentPage) of \(self.totalPages)). No more pages to increment.")
                } else if self.currentPage > self.totalPages && self.totalPages != 0 { // Sollte durch die Prüfung am Anfang abgefangen werden
                    print("ProductListViewModel: Warning - currentPage (\(self.currentPage)) somehow exceeded totalPages (\(self.totalPages)) after load.")
                }


            } catch let error as WooCommerceAPIError {
                self.errorMessage = "Fehler beim Laden der Produkte: \(error.localizedDescription)"
                print("ProductListViewModel Error (WooCommerceAPIError) for cat \(categoryId), page \(self.currentPage): \(error.localizedDescription)")
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
                print("ProductListViewModel Error (Unknown) for cat \(categoryId), page \(self.currentPage): \(error.localizedDescription)")
            }
        }
    }
    
    // Methode zum Nachladen von Inhalten
    func loadMoreContentIfNeeded(currentItem product: WooCommerceProduct?) {
        guard let currentCatId = self.currentCategoryId else {
            print("ProductListViewModel (loadMore): No currentCategoryId set. Aborting.")
            return
        }

        // Wenn product nil ist (z.B. Footer der Liste), und es mehr Seiten gibt, und nicht bereits geladen wird
        if product == nil {
            if !isLoadingMore && !isLoading && currentPage <= totalPages {
                print("ProductListViewModel (loadMore): currentItem is nil, attempting to load next page.")
                fetchProducts(categoryId: currentCatId, initialLoad: false)
            }
            return
        }
        
        // Finde den Index des aktuellen Produkts
        guard let productIndex = products.firstIndex(where: { $0.id == product?.id }) else {
            print("ProductListViewModel (loadMore): currentItem \(product?.id ?? -1) not found in products list. Aborting.")
            return
        }

        // Schwelle zum Nachladen (z.B. wenn die letzten 5 Elemente erreicht sind)
        let threshold = 5
        let thresholdIndex = products.index(products.endIndex, offsetBy: -threshold, limitedBy: products.startIndex) ?? products.startIndex
        
        // Lade mehr, wenn der Index die Schwelle erreicht oder überschreitet,
        // es mehr Seiten gibt und nicht bereits geladen wird.
        if productIndex >= thresholdIndex && !isLoadingMore && !isLoading && currentPage <= totalPages {
            print("ProductListViewModel (loadMore): Threshold reached for item \(product?.id ?? -1) at index \(productIndex). Loading more.")
            fetchProducts(categoryId: currentCatId, initialLoad: false)
        }
    }
}
