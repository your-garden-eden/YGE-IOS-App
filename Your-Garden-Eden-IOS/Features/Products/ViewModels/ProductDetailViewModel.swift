//
//  ProductDetailViewModel.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 06.06.25.
//


import SwiftUI

@MainActor
class ProductDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var product: WooCommerceProduct?
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var selectedVariation: WooCommerceProductVariation?
    
    // Status-Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let productSlug: String
    private let apiManager = WooCommerceAPIManager.shared

    // MARK: - Initializer
    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        self.productSlug = productSlug
        self.product = initialProductData
        print("ProductDetailViewModel (init): Initial product data provided for slug '\(productSlug)'.")
    }

    // MARK: - Data Fetching
    func fetchProductDetails() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        print("ProductDetailViewModel (fetchProductDetails): Loading details for slug: \(productSlug)")

        do {
            // Schritt 1: Lade das Hauptprodukt, falls es noch nicht vorhanden ist
            if self.product == nil {
                self.product = try await apiManager.getProductBySlug(productSlug: productSlug)
            }
            
            guard let currentProduct = self.product else {
                throw WooCommerceAPIError.noData // Oder ein spezifischerer Fehler
            }

            // Schritt 2: Lade die Produktvariationen, falls das Produkt variabel ist
            if currentProduct.type == .variable && !currentProduct.variations.isEmpty {
                print("ProductDetailViewModel (fetchProductDetails): Product is variable. Fetching variations for ID \(currentProduct.id)...")
                self.variations = try await apiManager.getProductVariations(productId: currentProduct.id)
                // Optional: Setze eine Standard-Variation, falls vorhanden
                self.selectedVariation = self.variations.first
            } else {
                self.variations = []
            }
            
            print("ProductDetailViewModel (fetchProductDetails): Successfully loaded details.")

        } catch let error as WooCommerceAPIError {
            self.errorMessage = error.localizedDescriptionForUser
            print("ProductDetailViewModel Error: \(error.debugDescription)")
        } catch {
            self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
            print("ProductDetailViewModel Error (Unknown): \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}