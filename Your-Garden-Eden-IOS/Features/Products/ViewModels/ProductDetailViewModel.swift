import SwiftUI

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var product: WooCommerceProduct?
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var relatedProducts: [WooCommerceProduct] = []
    @Published var selectedImage: WooCommerceImage?
    
    @Published var displayPrice: String = "..."

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let initialProductData: WooCommerceProduct?

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        self.initialProductData = initialProductData
    }

    func selectImage(_ image: WooCommerceImage) {
        withAnimation { self.selectedImage = image }
    }
    
    func fetchProductDetails(slug: String) async {
        try? await Task.sleep(nanoseconds: 1)
        
        if product != nil && !isLoading { return }

        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let currentProduct: WooCommerceProduct
            
            // --- DIE ENDGÜLTIGE KORREKTUR ---
            // Wir behandeln den optionalen Rückgabewert des API-Aufrufs korrekt.
            if let initialData = self.initialProductData {
                currentProduct = initialData
            } else {
                // Wir versuchen, das Produkt zu laden.
                guard let fetchedProduct = try await WooCommerceAPIManager.shared.getProductBySlug(productSlug: slug) else {
                    // Wenn der API-Aufruf 'nil' zurückgibt, werfen wir einen spezifischen Fehler.
                    throw WooCommerceAPIError.productNotFound
                }
                // Nur wenn das Produkt gefunden wurde, weisen wir es zu.
                currentProduct = fetchedProduct
            }
            
            // Ab hier ist 'currentProduct' garantiert ein gültiges Produkt.
            self.product = currentProduct
            self.selectedImage = currentProduct.images.first

            let currencySymbol = currentProduct.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"
            self.displayPrice = await PriceFormatter.formatPrice(from: currentProduct.priceHtml) ?? "\(currencySymbol)\(currentProduct.price)"
            
            if currentProduct.type == .variable && !currentProduct.variations.isEmpty {
                self.variations = try await WooCommerceAPIManager.shared.getProductVariations(productId: currentProduct.id)
            }
            
            await fetchRelatedProducts()

        } catch let error as WooCommerceAPIError {
            // Unser 'catch'-Block kann jetzt den neuen Fehlerfall elegant behandeln.
            self.errorMessage = error.localizedDescriptionForUser
            print("ProductDetailViewModel Error: \(error.debugDescription)")
        } catch {
            self.errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
            print("ProductDetailViewModel Error (Unknown): \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
    
    private func fetchRelatedProducts() async {
        guard let product = self.product, !product.relatedIds.isEmpty else { return }
        if !relatedProducts.isEmpty { return }
        
        do {
            let container = try await WooCommerceAPIManager.shared.getProducts(include: product.relatedIds)
            self.relatedProducts = container.products
        } catch {
            print("ProductDetailViewModel: Failed to fetch related products. Error: \(error.localizedDescription)")
        }
    }
}
