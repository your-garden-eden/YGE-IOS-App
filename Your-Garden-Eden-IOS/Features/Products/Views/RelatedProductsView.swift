// DATEI: RelatedProductsView.swift
// PFAD: Features/Products/Views/Components/RelatedProductsView.swift
// ZWECK: Stellt eine horizontal scrollbare Liste von ähnlichen oder empfohlenen
//        Produkten dar, typischerweise am Ende einer Produktdetailseite.

import SwiftUI
import Combine

struct RelatedProductsView: View {
    // Ein Wrapper, um Produkte in einer ForEach-Schleife eindeutig zu identifizieren,
    // selbst wenn das gleiche Produkt mehrmals zur Endlos-Scroll-Illusion angezeigt wird.
    struct IdentifiableDisplayProduct: Identifiable {
        let id = UUID()
        let product: WooCommerceProduct
    }
    
    let products: [IdentifiableDisplayProduct]

    @State private var currentIndex = 0
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common)
    @State private var cancellable: AnyCancellable?

    var body: some View {
        // Verdoppelt die Produktliste, um einen nahtlosen Übergang beim Zurücksetzen des Timers zu ermöglichen.
        let displayableProducts = products.count > 1 ? (products + products) : products

        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Layout.Spacing.medium) {
                    ForEach(Array(displayableProducts.enumerated()), id: \.offset) { (index, identifiableProduct) in
                        NavigationLink(value: identifiableProduct.product) {
                            ProductCardView(product: identifiableProduct.product)
                                .frame(width: 160)
                        }
                        .buttonStyle(.plain)
                        .id(index)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, AppTheme.Layout.Spacing.xSmall)
            }
            // Deaktiviert das manuelle Scrollen, wenn es nur ein Produkt gibt, um Verwirrung zu vermeiden.
            .simultaneousGesture(products.count <= 1 ? DragGesture().onChanged({_ in}) : nil)
            .onReceive(timer) { _ in
                guard products.count > 1 else { return }
                currentIndex += 1
                withAnimation(.easeInOut(duration: 0.8)) {
                    proxy.scrollTo(currentIndex, anchor: .center)
                }
                // Wenn das Ende der ursprünglichen Liste erreicht ist, wird zum Anfang zurückgesetzt.
                if currentIndex == products.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        currentIndex = 0
                        proxy.scrollTo(0, anchor: .center)
                    }
                }
            }
        }
        .onAppear {
            // Der Timer wird erst gestartet, wenn die View sichtbar ist, um Ressourcen zu sparen.
            self.cancellable = self.timer.connect() as? AnyCancellable
        }
        .onDisappear {
            // Der Timer wird gestoppt, wenn die View nicht mehr sichtbar ist.
            self.cancellable?.cancel()
        }
    }
}
