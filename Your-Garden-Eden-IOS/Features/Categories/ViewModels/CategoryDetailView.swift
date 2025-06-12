// Features/Categories/Views/CategoryDetailView.swift

import SwiftUI

struct CategoryDetailView: View {
    @StateObject private var viewModel: CategoryDetailViewModel

    init(category: WooCommerceCategory) {
        _viewModel = StateObject(wrappedValue: CategoryDetailViewModel(category: category))
    }

    var body: some View {
        List {
            // Die ForEach-Schleife ist das Herzstück der Ansicht.
            ForEach(viewModel.products) { product in
                
                // Wir verwenden den ZStack, um die gesamte Karte klickbar zu machen.
                ZStack {
                    // Die sichtbare Produktkarte.
                    ProductCardView(product: product)
                    
                    // Der unsichtbare Navigations-Trigger.
                    // Er reagiert auf Klicks und übergibt das `product`-Objekt
                    // an den zentralen NavigationStack in der ContentView.
                    NavigationLink(value: product) {
                        EmptyView()
                    }
                    .opacity(0)
                }
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear) // Stellt sicher, dass der Hintergrund der Liste durchscheint
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationTitle(viewModel.category.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Lade die Produkte, wenn die Ansicht erscheint.
            await viewModel.fetchProducts()
        }
        // DER ÜBERFLÜSSIGE .navigationDestination WURDE HIER ENTFERNT
        .overlay {
            // Zeige einen Ladeindikator, während die Produkte geladen werden.
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}
