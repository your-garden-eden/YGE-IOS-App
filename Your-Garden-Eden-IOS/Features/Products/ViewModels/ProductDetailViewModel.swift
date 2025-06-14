//// Dateiname: ProductDetailViewModel.swift (MODIFIZIERT)
//
//import SwiftUI
//
//@MainActor
//class ProductDetailViewModel: ObservableObject {
//    
//    // Bestehende Zustände
//    @Published private(set) var variations: [WooCommerceProductVariation] = []
//    @Published private(set) var isLoadingVariations: Bool = false
//    @Published private(set) var variationError: String?
//    @Published var quantity: Int = 1
//    @Published private(set) var isAddingToCart: Bool = false
//
//    // FINALE KORREKTUR: Neue Zustände für die Cross-Sells
//    @Published private(set) var crossSellProducts: [WooCommerceProduct] = []
//    @Published private(set) var isLoadingCrossSells: Bool = false
//    
//    private let api = WooCommerceAPIManager.shared
//
//    init() {}
//    
//    // MARK: - Ladefunktionen
//    
//    func loadVariations(for product: WooCommerceProduct) async {
//        guard product.type == .variable, variations.isEmpty, !isLoadingVariations else { return }
//        
//        self.isLoadingVariations = true
//        self.variationError = nil
//        
//        do {
//            let fetchedVariations = try await api.fetchProductVariations(productId: product.id)
//            self.variations = fetchedVariations
//        } catch {
//            self.variationError = "Die Produktvarianten konnten nicht geladen werden."
//        }
//        
//        self.isLoadingVariations = false
//    }
//    
//    // FINALE KORREKTUR: Neue Funktion zum Laden der Cross-Sell-Produkte.
//    func loadCrossSells(for product: WooCommerceProduct) async {
//        guard !product.crossSellIds.isEmpty, !isLoadingCrossSells else { return }
//
//        self.isLoadingCrossSells = true
//        
//        do {
//            let response = try await api.fetchProducts(include: product.crossSellIds)
//            self.crossSellProducts = response.products
//        } catch {
//            // Fehler hier ist nicht kritisch, wir zeigen die Sektion einfach nicht an.
//            print("🔴 ProductDetailViewModel: Failed to load cross-sell products: \(error.localizedDescription)")
//            self.crossSellProducts = [] // Sicherstellen, dass die Liste leer ist
//        }
//        
//        self.isLoadingCrossSells = false
//    }
//
//    // MARK: - Warenkorb-Funktion
//    func addSimpleProductToCart(productID: Int) async {
//        // ... (unverändert)
//        isAddingToCart = true
//        await CartAPIManager.shared.addItem(productId: productID, quantity: self.quantity)
//        isAddingToCart = false
//    }
//}
