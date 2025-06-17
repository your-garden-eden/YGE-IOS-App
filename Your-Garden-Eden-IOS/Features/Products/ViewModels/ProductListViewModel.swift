// Path: Your-Garden-Eden-IOS/Features/Products/ViewModels/ProductListViewModel.swift
// VERSION 2.1 (FINAL - With Search Logic)

import Foundation
import Combine

@MainActor
class ProductListViewModel: ObservableObject {
    
    enum Context: Equatable { // Equatable ist wichtig, um Änderungen zu erkennen
        case categoryId(Int)
        case onSale
        case featured
        case byIds([Int])
        case search(String)
    }

    @Published var products: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    
    var headline: String?
    
    // 'private(set)' erlaubt uns, den context von außen zu lesen, aber nur intern zu ändern.
    @Published private(set) var context: Context
    private var currentPage = 1
    private var totalPages: Int?
    private let api = WooCommerceAPIManager.shared
    
    // NEU: Ein Set für unsere Combine-Beobachter
    private var cancellables = Set<AnyCancellable>()
    // NEU: Ein Subject, das die Suchanfragen entgegennimmt
    private let searchQuerySubject = PassthroughSubject<String, Never>()

    var canLoadMore: Bool {
        // Die Logik für "Load More" gilt nicht, wenn wir suchen.
        guard let total = totalPages, !isLoading, !isLoadingMore, context != .search("") else { return false }
        return currentPage <= total
    }

    init(context: Context, headline: String? = nil) {
        self.context = context
        self.headline = headline
        
        // ===================================================================
        // **NEUE LOGIK: Debouncing für die Suche**
        // ===================================================================
        // Beobachtet die Suchanfragen, wartet 500ms nach der letzten Eingabe,
        // entfernt Duplikate und startet dann die Ladefunktion.
        searchQuerySubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchQuery in
                guard let self = self else { return }
                Task {
                    await self.performSearch(query: searchQuery)
                }
            }
            .store(in: &cancellables)
    }
    
    // ===================================================================
    // **NEUE ÖFFENTLICHE FUNKTION: Trigger für die Suche**
    // ===================================================================
    /// Diese Funktion wird von der View aufgerufen, um eine neue Suche auszulösen.
    func search(for query: String) {
        // Leere Suchanfragen unter 3 Zeichen ignorieren, um unnötige API-Calls zu vermeiden
        if query.count < 3 && !query.isEmpty {
            self.products = []
            self.errorMessage = "Bitte mindestens 3 Zeichen eingeben."
            return
        }
        searchQuerySubject.send(query)
    }
    
    private func performSearch(query: String) async {
        if query.isEmpty {
            // Wenn die Suche leer ist, kehren wir zum ursprünglichen Kontext zurück
            // HINWEIS: Hier müsste man den "ursprünglichen" Kontext speichern,
            // für den Moment laden wir die Kategorie neu, was ein guter Start ist.
            self.context = .categoryId(0) // Annahme, wir kehren zu einer "Alle"-Ansicht zurück
            await loadProducts()
        } else {
            self.context = .search(query)
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        guard !isLoading else { return }
        
        self.currentPage = 1
        self.products = []
        self.totalPages = nil
        self.isLoading = true
        self.errorMessage = nil
        
        await fetchProductData()
        
        self.isLoading = false
    }
    
    func loadMoreProducts() async {
        guard canLoadMore else { return }
        
        self.isLoadingMore = true
        await fetchProductData()
        self.isLoadingMore = false
    }
    
    private func fetchProductData() async {
        do {
            let response: WooCommerceProductsResponseContainer
            
            switch context {
            case .categoryId(let id):
                response = try await api.fetchProducts(categoryId: id, page: currentPage)
            case .onSale:
                response = try await api.fetchProducts(page: currentPage, onSale: true)
            case .featured:
                response = try await api.fetchProducts(page: currentPage, featured: true)
            case .byIds(let ids):
                response = try await api.fetchProducts(page: 1, include: ids)
            case .search(let query):
                // Wenn die Suchanfrage leer ist, keine Anfrage senden
                guard !query.isEmpty else {
                    self.products = []
                    return
                }
                response = try await api.fetchProducts(page: currentPage, searchQuery: query)
            }
            
            var fetchedProducts = response.products
            
            try await withThrowingTaskGroup(of: (Int, String?).self) { group in
                for product in fetchedProducts where product.type == "variable" {
                    group.addTask {
                        let variations = try await self.api.fetchProductVariations(productId: product.id)
                        let range = PriceFormatter.calculatePriceRange(from: variations)
                        return (product.id, range)
                    }
                }
                
                for try await (productId, range) in group {
                    if let range = range, let index = fetchedProducts.firstIndex(where: { $0.id == productId }) {
                        fetchedProducts[index].priceRangeDisplay = range
                    }
                }
            }
            
            if self.currentPage == 1 {
                self.products = fetchedProducts
            } else {
                self.products.append(contentsOf: fetchedProducts)
            }
            
            self.totalPages = response.totalPages
            self.currentPage += 1
            
        } catch let apiError as WooCommerceAPIError {
            self.errorMessage = apiError.localizedDescriptionForUser
        } catch {
            self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
        }
    }
}
