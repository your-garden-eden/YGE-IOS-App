import Foundation

@MainActor
class CategoryLandingViewModel: ObservableObject {
    
    @Published var subCategories: [WooCommerceCategory] = []
    @Published var viewState: ViewState = .loading
    
    enum ViewState: Equatable {
        case loading
        case showSubCategories
        case showProducts
        case error(String)
        case empty
    }
    
    private let category: WooCommerceCategory
    private let api = WooCommerceAPIManager.shared
    
    init(category: WooCommerceCategory) {
        self.category = category
    }
    
    func loadContent() async {
        guard viewState == .loading else { return }

        do {
            let fetchedSubCategories = try await api.fetchCategories(parent: category.id)
            
            if !fetchedSubCategories.isEmpty {
                self.subCategories = fetchedSubCategories.sorted { ($0.menu_order ?? 999) < ($1.menu_order ?? 999) }
                self.viewState = .showSubCategories
            } else {
                let productResponse = try await api.fetchProducts(categoryId: category.id, perPage: 1)
                
                if productResponse.products.isEmpty {
                    self.viewState = .empty
                } else {
                    self.viewState = .showProducts
                }
            }
        } catch let apiError as WooCommerceAPIError {
            self.viewState = .error(apiError.localizedDescriptionForUser)
        } catch {
            self.viewState = .error("Ein unerwarteter Fehler ist aufgetreten.")
        }
    }
}
