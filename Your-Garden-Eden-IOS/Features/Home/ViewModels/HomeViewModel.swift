// Features/Home/ViewModels/HomeViewModel.swift
import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var bestsellerProducts: [WooCommerceProduct] = []

    private let wooAPIManager = WooCommerceAPIManager.shared

    init() {
        print("HomeViewModel initialized.")
        // loadDataForHomeView() // Wird in .onAppear der View aufgerufen
    }

    func loadDataForHomeView() {
        print("HomeViewModel: loadDataForHomeView called - Attempting to load bestseller products.")
        self.isLoading = true
        self.errorMessage = nil
        // self.bestsellerProducts = [] // Optional: Leeren vor dem Neuladen

        Task {
            do {
                let container = try await wooAPIManager.getProducts(
                    perPage: 20,            // HIER DIE ÄNDERUNG: Lade bis zu 20 Bestseller-Produkte
                    orderBy: "popularity"
                )
                
                self.bestsellerProducts = container.products
                if container.products.isEmpty {
                    print("HomeViewModel: No bestseller products found.")
                } else {
                    print("HomeViewModel: Successfully loaded \(container.products.count) bestseller products.")
                }
                
            } catch let error as WooCommerceAPIError {
                self.errorMessage = "Fehler beim Laden der Bestseller: \(error.localizedDescription)"
                print("HomeViewModel Error (WooCommerceAPIError): \(error.localizedDescription)")
            } catch {
                self.errorMessage = "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)"
                print("HomeViewModel Error (Unknown): \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}
