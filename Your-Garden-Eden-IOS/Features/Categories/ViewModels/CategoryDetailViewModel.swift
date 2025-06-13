////
////  CategoryDetailViewModel.swift
////  Your-Garden-Eden-IOS
////
////  Created by Josef Ewert on 11.06.25.
////
//
//
//// Features/Categories/ViewModels/CategoryDetailViewModel.swift
//
//import Foundation
//
//@MainActor
//class CategoryDetailViewModel: ObservableObject {
//    @Published private(set) var products: [WooCommerceProduct] = []
//    @Published private(set) var isLoading = false
//    @Published private(set) var errorMessage: String?
//    
//    let category: WooCommerceCategory
//
//    init(category: WooCommerceCategory) {
//        self.category = category
//    }
//
//    func fetchProducts() async {
//        // Nur laden, wenn die Liste leer ist, um unnötige API-Aufrufe zu vermeiden.
//        guard products.isEmpty else { return }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            // Ruft die Produkte für die gegebene Kategorie-ID ab.
//            let productContainer = try await WooCommerceAPIManager.shared.fetchProducts(categoryId: category.id, perPage: 50) // Lade bis zu 50 Produkte
//            self.products = productContainer.products
//        } catch {
//            self.errorMessage = "Produkte konnten nicht geladen werden."
//            print("🔴 CategoryDetailViewModel Error: \(error.localizedDescription)")
//        }
//        
//        isLoading = false
//    }
//}
