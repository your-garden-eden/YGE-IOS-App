import SwiftUI

struct IdentifiableDisplayProduct: Identifiable {
    let id = UUID()
    let product: WooCommerceProduct
}

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var product: WooCommerceProduct?
    @Published var variations: [WooCommerceProductVariation] = []
    @Published var relatedProducts: [WooCommerceProduct] = []
    @Published var displayRelatedProducts: [IdentifiableDisplayProduct] = []
    @Published var displayPrice: String = "..."
    @Published var formattedShortDescription: AttributedString?
    @Published var formattedDescription: AttributedString?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // WICHTIG: Die ausgewählte Bild-Property muss auch hier sein.
    @Published var selectedImage: WooCommerceImage?

    private let productSlug: String
    private let initialProductData: WooCommerceProduct?

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        self.productSlug = productSlug
        self.initialProductData = initialProductData
        if let initialData = initialProductData {
            updateState(with: initialData)
        }
    }
    
    func selectImage(_ image: WooCommerceImage) {
        withAnimation { self.selectedImage = image }
    }
    
    func loadDetails() async {
        if isLoading { return }
        if let product = self.product, (product.type != .variable || !self.variations.isEmpty) { return }
        isLoading = true
        errorMessage = nil
        do {
            let currentProduct: WooCommerceProduct
            if let initialData = self.initialProductData, self.product == nil {
                currentProduct = initialData
            } else {
                guard let fetchedProduct = try await WooCommerceAPIManager.shared.getProductBySlug(productSlug: self.productSlug) else {
                    throw WooCommerceAPIError.productNotFound
                }
                currentProduct = fetchedProduct
            }
            let fetchedVariations = try await fetchVariations(for: currentProduct)
            let fetchedRelatedProducts = try await fetchRelatedProducts(for: currentProduct)
            updateState(with: currentProduct, variations: fetchedVariations, relatedProducts: fetchedRelatedProducts)
        } catch let error as WooCommerceAPIError {
            errorMessage = error.localizedDescriptionForUser
            print("ProductDetailViewModel Error: \(error.debugDescription)")
        } catch {
            errorMessage = "Ein unerwarteter Fehler ist aufgetreten."
            print("ProductDetailViewModel Error (Unknown): \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func updateState(with product: WooCommerceProduct, variations: [WooCommerceProductVariation]? = nil, relatedProducts: [WooCommerceProduct]? = nil) {
        let currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"
        let formattedPrice = PriceFormatter.formatPriceString(from: product.priceHtml, fallbackPrice: product.price, currencySymbol: currencySymbol)
        self.formattedShortDescription = HTMLParser.parse(html: product.shortDescription)
        self.formattedDescription = HTMLParser.parse(html: product.description)
        self.product = product
        self.selectedImage = product.images.first
        self.displayPrice = formattedPrice.display
        if let variations = variations {
            self.variations = variations
        }
        if let relatedProducts = relatedProducts {
            self.relatedProducts = relatedProducts
            self.displayRelatedProducts = createLoopedRelatedProducts(from: relatedProducts)
            
            // --- DEBUG-PRINT 2 ---
            print("--- DEBUG (ViewModel): 'displayRelatedProducts' wurde mit \(self.displayRelatedProducts.count) Elementen gefüllt.")
        }
    }
    
    private func fetchVariations(for product: WooCommerceProduct) async throws -> [WooCommerceProductVariation] {
        if product.type == .variable && !product.variations.isEmpty {
            return try await WooCommerceAPIManager.shared.getProductVariations(productId: product.id)
        }
        return []
    }
    
    private func fetchRelatedProducts(for product: WooCommerceProduct) async throws -> [WooCommerceProduct] {
        // --- DEBUG-PRINT 1 ---
        print("--- DEBUG (ViewModel): Prüfe 'relatedIds' für Produkt \(product.id). Anzahl: \(product.relatedIds.count). IDs: \(product.relatedIds)")

        if !product.relatedIds.isEmpty {
            let container = try await WooCommerceAPIManager.shared.getProducts(include: product.relatedIds)
            return container.products
        }
        return []
    }
    
    private func createLoopedRelatedProducts(from products: [WooCommerceProduct]) -> [IdentifiableDisplayProduct] {
        guard !products.isEmpty else { return [] }
        var loopedProducts: [IdentifiableDisplayProduct] = []
        while loopedProducts.count < 20 {
            for product in products {
                if loopedProducts.count < 20 {
                    loopedProducts.append(IdentifiableDisplayProduct(product: product))
                } else {
                    break
                }
            }
        }
        return loopedProducts
    }
}
