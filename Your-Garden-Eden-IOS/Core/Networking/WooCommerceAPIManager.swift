import Foundation

// AnyEncodable Struct
struct AnyEncodable: Encodable { /* ... Definition ... */ }

class WooCommerceAPIManager {
    static let shared = WooCommerceAPIManager()
    // private let proxyService = FirebaseProxyService.shared // Wird für Simulation nicht direkt gebraucht

    private init() {}

    func getCategories(parent: Int? = nil,
                       perPage: Int = 100,
                       page: Int = 1,
                       hideEmpty: Bool = true,
                       orderby: String = "menu_order",
                       order: String = "asc",
                       completion: @escaping (Result<[WooCommerceCategory], Error>) -> Void) {
        
        print("WooCommerceAPIManager: getCategories aufgerufen - SIMULIERE Daten, da Cloud Function noch nicht aktiv.")

        // --- BEGINN SIMULATION ---
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Kurze Verzögerung
            let mockCategories: [WooCommerceCategory] = [
                .placeholder,
                WooCommerceCategory(id: 2, name: "Gartenwerkzeuge (Sim)", slug: "werkzeuge-sim", parent: 0, description: "Simulierte Daten", display: "products", image: nil, menuOrder: 2, count: 7),
                WooCommerceCategory(id: 3, name: "Pflanzen (Sim)", slug: "pflanzen-sim", parent: 0, description: "Simulierte Daten", display: "products", image: nil, menuOrder: 3, count: 22)
            ]
            completion(.success(mockCategories))
            
            // Oder um einen Fehler zu simulieren:
            // let error = NSError(domain: "APIManagerSim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulierter Fehler beim Laden der Kategorien."])
            // completion(.failure(error))
            
            // Oder um leere Daten zu simulieren:
            // completion(.success([]))
        }
        // --- ENDE SIMULATION ---
    }
    // ...
}
