//import Foundation
//import Combine
//
//@MainActor
//class WishlistViewModel: ObservableObject {
//    @Published var wishlistProducts: [WooCommerceProduct] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//
//    private var wishlistState: WishlistState
//    private let wooAPIManager = WooCommerceAPIManager.shared
//    private var cancellables = Set<AnyCancellable>()
//    private var currentProductIdsFetching: Set<Int> = []
//
//    init(wishlistState: WishlistState) {
//        self.wishlistState = wishlistState
//        print("🤍 WishlistViewModel initialized.")
//
//        wishlistState.$wishlistProductIds
//            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
//            .removeDuplicates()
//            .sink { [weak self] productIds in
//                guard let self = self else { return }
//                // Da fetchWishlistProducts jetzt async ist, müssen wir es in einem Task aufrufen.
//                Task {
//                    if !productIds.isEmpty && self.currentProductIdsFetching != productIds {
//                        await self.fetchWishlistProducts(ids: productIds)
//                    } else if productIds.isEmpty {
//                        if !self.wishlistProducts.isEmpty || self.errorMessage != nil || self.isLoading {
//                            self.wishlistProducts = []
//                            self.errorMessage = nil
//                            self.isLoading = false
//                            self.currentProductIdsFetching = []
//                        }
//                    }
//                }
//            }
//            .store(in: &cancellables)
//    }
//
//    // --- KORREKTUR HIER: Die Funktion wird als `async` deklariert ---
//    func fetchWishlistProducts(ids: Set<Int>? = nil) async {
//        let productIdsToFetch = ids ?? wishlistState.wishlistProductIds
//
//        guard !productIdsToFetch.isEmpty else {
//            if !self.wishlistProducts.isEmpty || self.errorMessage != nil || self.isLoading || !self.currentProductIdsFetching.isEmpty {
//                self.wishlistProducts = []
//                self.errorMessage = nil
//                self.isLoading = false
//                self.currentProductIdsFetching = []
//            }
//            return
//        }
//        
//        // Verhindert doppelte Ladevorgänge
//        guard !isLoading || currentProductIdsFetching != productIdsToFetch else { return }
//
//        self.isLoading = true
//        self.errorMessage = nil
//        self.currentProductIdsFetching = productIdsToFetch
//
//        // Wir brauchen hier keinen neuen `Task`, da die Funktion selbst schon in einem asynchronen Kontext läuft.
//        do {
//            let responseContainer = try await wooAPIManager.fetchProducts(perPage: productIdsToFetch.count, include: Array(productIdsToFetch))
//            
//            // Überprüfen, ob sich die Anfrage in der Zwischenzeit geändert hat
//            guard self.currentProductIdsFetching == productIdsToFetch else {
//                return
//            }
//
//            let actualFetchedProducts = responseContainer.products
//            self.wishlistProducts = actualFetchedProducts.sorted(by: { $0.name < $1.name })
//
//            if actualFetchedProducts.isEmpty && !productIdsToFetch.isEmpty {
//                print("🤍 WishlistViewModel: No products returned for given IDs.")
//            }
//
//        } catch {
//            guard self.currentProductIdsFetching == productIdsToFetch else {
//                return
//            }
//            print("🔴 WishlistViewModel Error: \(error.localizedDescription)")
//            self.errorMessage = "Produktdetails konnten nicht geladen werden."
//            self.wishlistProducts = []
//        }
//        
//        self.isLoading = false
//    }
//
//    // --- KORREKTUR HIER: Auch diese Funktion muss `async` sein ---
//    func retryLoadProducts() async {
//        await fetchWishlistProducts(ids: wishlistState.wishlistProductIds)
//    }
//}
