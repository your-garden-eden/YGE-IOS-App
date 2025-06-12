// Features/Wishlist/Views/WishlistView.swift

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var wishlistState: WishlistState
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        Group {
            if wishlistState.isLoading && wishlistState.wishlistProducts.isEmpty {
                ProgressView("Lade Wunschliste...")
            } else if wishlistState.wishlistProducts.isEmpty {
                emptyWishlistView
            } else {
                productList(products: wishlistState.wishlistProducts)
            }
        }
        .navigationTitle("Wunschliste")
        .task {
            // KORREKTUR: Der korrekte Funktionsname wird verwendet.
            if wishlistState.wishlistProducts.isEmpty && authManager.isLoggedIn {
                await wishlistState.fetchWishlistProducts()
            }
        }
        .refreshable {
            // KORREKTUR: Der korrekte Funktionsname wird auch hier verwendet.
            await wishlistState.fetchWishlistProducts()
        }
    }

    private var emptyWishlistView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            Text("Deine Wunschliste ist leer")
                .font(.headline)
            Text("Füge Produkte hinzu, indem du auf das Herz-Symbol tippst.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private func productList(products: [WooCommerceProduct]) -> some View {
        List {
            ForEach(products) { product in
                NavigationLink(value: product) {
                    HStack {
                        AsyncImage(url: product.images.first?.src.asURL()) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        
                        Text(product.name.strippingHTML())
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
    }

    private func deleteItems(at offsets: IndexSet) {
        let productsToDelete = offsets.map { wishlistState.wishlistProducts[$0] }
        
        for product in productsToDelete {
            let parentProductId = product.parentId == 0 ? product.id : product.parentId
            let variationId = product.parentId != 0 ? product.id : nil
            
            wishlistState.removeProduct(productId: parentProductId, variationId: variationId)
        }
    }
}

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthManager.shared
        let wishlistState = WishlistState(authManager: authManager)
        
        return NavigationView {
            WishlistView()
                .environmentObject(wishlistState)
                .environmentObject(authManager)
        }
    }
}
