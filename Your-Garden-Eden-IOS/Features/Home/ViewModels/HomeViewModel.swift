//import Foundation
//import Combine
//
//struct DisplayableMainCategory: Identifiable, Hashable {
//    let id: Int
//    let appItem: AppNavigationItem
//    
//    static func == (lhs: DisplayableMainCategory, rhs: DisplayableMainCategory) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
//
//@MainActor
//final class HomeViewModel: ObservableObject {
//    
//    private let wooAPIManager: WooCommerceAPIManager
//    
//    @Published private(set) var displayableCategories: [DisplayableMainCategory] = []
//    @Published private(set) var isLoadingCategories: Bool = false
//    @Published private(set) var categoryErrorMessage: String?
//    
//    @Published private(set) var bestsellerProducts: [WooCommerceProduct] = []
//    @Published private(set) var isLoadingBestsellers: Bool = false
//    @Published private(set) var bestsellerErrorMessage: String?
//    
//    var isInitialLoading: Bool {
//        return isLoadingCategories || isLoadingBestsellers
//    }
//
//    init(wooAPIManager: WooCommerceAPIManager = .shared) {
//        self.wooAPIManager = wooAPIManager
//    }
//    
//    func loadAllData() async {
//        guard displayableCategories.isEmpty && bestsellerProducts.isEmpty else { return }
//        
//        await withTaskGroup(of: Void.self) { group in
//            group.addTask { await self.loadCategories() }
//            group.addTask { await self.loadBestsellerProducts() }
//        }
//    }
//    
//    private func loadCategories() async {
//        isLoadingCategories = true
//        categoryErrorMessage = nil
//        defer { isLoadingCategories = false }
//        
//        do {
//            // KORREKTUR: Ruft die korrekte `fetchCategories`-Methode auf
//            let wooCommerceCategories = try await wooAPIManager.fetchCategories(parent: 0)
//            let categoryIdMap = Dictionary(uniqueKeysWithValues: wooCommerceCategories.map { ($0.slug, $0.id) })
//            
//            let mergedCategories: [DisplayableMainCategory] = AppNavigationData.items.compactMap { appItem in
//                if let categoryID = categoryIdMap[appItem.mainCategorySlug] {
//                    return DisplayableMainCategory(id: categoryID, appItem: appItem)
//                } else {
//                    print("⚠️ WARNUNG: Statische Kategorie '\(appItem.mainCategorySlug)' nicht auf dem Server gefunden.")
//                    return nil
//                }
//            }
//            self.displayableCategories = mergedCategories
//        } catch {
//            print("🔴 FEHLER (Kategorien): \(error)")
//            self.categoryErrorMessage = "Die Kategorien konnten nicht geladen werden."
//        }
//    }
//    
//    private func loadBestsellerProducts() async {
//        isLoadingBestsellers = true
//        bestsellerErrorMessage = nil
//        defer { isLoadingBestsellers = false }
//        
//        do {
//            // KORREKTUR: Ruft die korrekte `fetchProducts`-Methode auf
//            let container = try await wooAPIManager.fetchProducts(perPage: 20, orderBy: "popularity")
//            self.bestsellerProducts = container.products
//        } catch let error as WooCommerceAPIError {
//            print("🔴 FEHLER (Bestseller): \(error.localizedDescription)")
//            self.bestsellerErrorMessage = "Die Bestseller konnten nicht geladen werden."
//        } catch {
//            print("🔴 FEHLER (Bestseller): \(error.localizedDescription)")
//            self.bestsellerErrorMessage = "Ein unbekannter Fehler ist aufgetreten."
//        }
//    }
//}
