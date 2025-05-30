// Features/Wishlist/ViewModels/WishlistViewModel.swift
import SwiftUI
import Combine

@MainActor
class WishlistViewModel: ObservableObject {
    @Published var wishlistProducts: [WooCommerceProduct] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var wishlistState: WishlistState
    private let wooAPIManager = WooCommerceAPIManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentProductIdsFetching: Set<Int> = [] // Um doppelte Fetches für dieselben IDs zu vermeiden

    init(wishlistState: WishlistState) {
        self.wishlistState = wishlistState
        print("WishlistViewModel initialized.")

        wishlistState.$wishlistProductIds
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main) // Kurzes Debounce
            .removeDuplicates() // Nur bei tatsächlicher Änderung der IDs reagieren
            .sink { [weak self] productIds in
                guard let self = self else { return }
                print("WishlistViewModel: Received new product IDs from WishlistState: \(productIds.sorted()). Currently fetching: \(self.currentProductIdsFetching.sorted())")
                
                // Nur laden, wenn die IDs nicht leer sind und sich von den aktuell ladenden unterscheiden,
                // oder wenn der ViewModel gerade initialisiert wurde und IDs vorhanden sind.
                if !productIds.isEmpty && self.currentProductIdsFetching != productIds {
                    self.fetchWishlistProducts(ids: productIds)
                } else if productIds.isEmpty {
                    // Wenn die IDs leer werden, Produkte leeren und Fehler zurücksetzen
                    if !self.wishlistProducts.isEmpty || self.errorMessage != nil || self.isLoading {
                        self.wishlistProducts = []
                        self.errorMessage = nil
                        self.isLoading = false // Wichtig, falls ein Ladevorgang lief und die Liste leer wurde
                        self.currentProductIdsFetching = []
                        print("WishlistViewModel: Wishlist is now empty. Cleared products, error message, and loading state.")
                    }
                }
            }
            .store(in: &cancellables)
    }

    func fetchWishlistProducts(ids: Set<Int>? = nil) {
        let productIdsToFetch = ids ?? wishlistState.wishlistProductIds

        guard !productIdsToFetch.isEmpty else {
            // Nur zurücksetzen, wenn sich der Zustand tatsächlich ändert
            if !self.wishlistProducts.isEmpty || self.errorMessage != nil || self.isLoading || !self.currentProductIdsFetching.isEmpty {
                self.wishlistProducts = []
                self.errorMessage = nil
                self.isLoading = false
                self.currentProductIdsFetching = []
                print("WishlistViewModel: No product IDs to fetch or wishlist is empty. Cleared state.")
            }
            return
        }

        // Verhindern, dass derselbe Satz von IDs mehrfach gleichzeitig gefetched wird,
        // wenn bereits ein Ladevorgang für genau diese IDs läuft.
        // Dies wird auch durch .removeDuplicates() im Sink unterstützt.
        if isLoading && currentProductIdsFetching == productIdsToFetch {
           print("WishlistViewModel: Already fetching these product IDs: \(productIdsToFetch.sorted())")
           return
        }

        print("WishlistViewModel: Attempting to fetch details for \(productIdsToFetch.count) wishlist IDs: \(productIdsToFetch.sorted())")
        self.isLoading = true
        self.errorMessage = nil // Fehler vor jedem neuen Versuch zurücksetzen
        self.currentProductIdsFetching = productIdsToFetch

        Task {
            do {
                // WooCommerceAPIManager.getProducts gibt WooCommerceProductsResponseContainer zurück
                let responseContainer = try await wooAPIManager.getProducts(perPage: productIdsToFetch.count, include: Array(productIdsToFetch))
                
                // Sicherstellen, dass wir immer noch für dieselben IDs laden (falls sich der State schnell geändert hat)
                guard self.currentProductIdsFetching == productIdsToFetch else {
                    print("WishlistViewModel: Product IDs changed during fetch. Discarding results for \(productIdsToFetch.sorted()). Current desired IDs: \(self.currentProductIdsFetching.sorted())")
                    // isLoading wird beim nächsten relevanten Fetch neu gesetzt.
                    return
                }

                // KORREKTUR: Zugriff auf die Produkte im Container
                let actualFetchedProducts = responseContainer.products

                self.wishlistProducts = actualFetchedProducts.sorted(by: { $0.name < $1.name }) // Oder eine andere sinnvolle Sortierung
                self.isLoading = false
                // self.errorMessage = nil // Bereits oben gesetzt, hier optional
                print("WishlistViewModel: Successfully fetched and assigned \(self.wishlistProducts.count) products for IDs \(productIdsToFetch.sorted()).")

                // KORREKTUR: Überprüfung auf leere Produktliste im Container
                if actualFetchedProducts.isEmpty && !productIdsToFetch.isEmpty {
                    print("WishlistViewModel: Successfully fetched, but no products returned for the given IDs (from container).")
                    // Dies könnte ein spezieller Zustand sein, z.B. "Produkte nicht mehr verfügbar"
                    // Für jetzt setzen wir keinen Fehler, sondern zeigen einfach eine leere Liste an.
                    // Man könnte hier auch eine spezifische Nachricht setzen:
                    // self.errorMessage = "Einige Produkte auf deiner Wunschliste sind nicht mehr verfügbar oder wurden nicht gefunden."
                }

            } catch {
                // Sicherstellen, dass der Fehler nur für den aktuellen Fetch-Versuch relevant ist
                guard self.currentProductIdsFetching == productIdsToFetch else {
                     print("WishlistViewModel: Product IDs changed during fetch (error case). Discarding error for \(productIdsToFetch.sorted()). Current desired IDs: \(self.currentProductIdsFetching.sorted())")
                    return
                }
                print("WishlistViewModel: Error fetching wishlist products: \(error.localizedDescription) (Full error: \(error))")
                self.errorMessage = "Details zu den Produkten konnten nicht geladen werden. Bitte versuche es später erneut."
                // self.errorMessage = "Details zu den Produkten konnten nicht geladen werden. (\(error.localizedDescription))" // Detailliertere Meldung
                self.isLoading = false
                self.wishlistProducts = [] // Bei Fehler leere Liste anzeigen, um inkonsistenten Zustand zu vermeiden
            }
        }
    }

    // Für den "Erneut versuchen"-Button in der View
    func retryLoadProducts() {
        print("WishlistViewModel: Retry load products triggered.")
        // Die aktuellen IDs vom WishlistState verwenden, um den Ladevorgang neu zu starten.
        // Der Sink sollte dies nicht automatisch tun, wenn sich die IDs nicht geändert haben,
        // daher ist ein direkter Aufruf von fetchWishlistProducts hier sinnvoll.
        // `currentProductIdsFetching` wird in fetchWishlistProducts neu gesetzt.
        fetchWishlistProducts(ids: wishlistState.wishlistProductIds)
    }
}
