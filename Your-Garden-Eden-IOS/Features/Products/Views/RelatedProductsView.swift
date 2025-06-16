import SwiftUI

struct IdentifiableDisplayProduct: Identifiable {
    let id = UUID()
    let product: WooCommerceProduct
}

struct RelatedProductsView: View {
    let products: [IdentifiableDisplayProduct]

    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        let displayableProducts = products.count > 1 ? (products + products) : products

        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppStyles.Spacing.medium) {
                    ForEach(Array(displayableProducts.enumerated()), id: \.offset) { (index, identifiableProduct) in
                        // MODERNISIERT: Verwendet `NavigationLink(value:)` für typsichere Navigation.
                        NavigationLink(value: identifiableProduct.product) {
                            ProductCardView(product: identifiableProduct.product)
                                .frame(width: 160)
                        }
                        .buttonStyle(.plain)
                        .id(index)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, AppStyles.Spacing.xSmall)
            }
            .simultaneousGesture(products.count <= 1 ? DragGesture().onChanged({_ in}) : nil)
            .onReceive(timer) { _ in
                guard products.count > 1 else { return }
                currentIndex += 1
                withAnimation(.easeInOut(duration: 0.8)) {
                    proxy.scrollTo(currentIndex, anchor: .center)
                }
                if currentIndex == products.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        currentIndex = 0
                        proxy.scrollTo(0, anchor: .center)
                    }
                }
            }
        }
        .onDisappear {
            self.timer.upstream.connect().cancel()
        }
    }
}
