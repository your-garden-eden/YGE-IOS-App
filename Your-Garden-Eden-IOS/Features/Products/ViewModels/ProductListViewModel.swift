//
//  ProductListViewModel.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 14.06.25.
//


// Path: Your-Garden-Eden-IOS/Features/Categories/ViewModels/ProductListViewModel.swift

import Foundation

@MainActor
class ProductListViewModel: ObservableObject {
    
    @Published private(set) var products: [WooCommerceProduct] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var canLoadMore = true
    
    private let categoryId: Int
    private let apiManager = WooCommerceAPIManager.shared
    private var currentPage = 1
    
    init(categoryId: Int) {
        self.categoryId = categoryId
        print("📦 ProductListViewModel initialized for category ID: \(categoryId)")
    }
    
    func loadProducts(initialLoad: Bool = false) async {
        guard !isLoading else { return }
        
        if initialLoad {
            currentPage = 1
            products = []
            canLoadMore = true
            errorMessage = nil
        }
        
        guard canLoadMore else { return }
        
        isLoading = true
        
        do {
            let response = try await apiManager.fetchProducts(categoryId: self.categoryId, page: self.currentPage)
            self.products.append(contentsOf: response.products)
            self.canLoadMore = response.totalPages > self.currentPage
            self.currentPage += 1
            
        } catch {
            self.errorMessage = "Produkte konnten nicht geladen werden."
            print("🔴 ProductListViewModel Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func isLastProduct(_ product: WooCommerceProduct) -> Bool {
        return products.last?.id == product.id
    }
}