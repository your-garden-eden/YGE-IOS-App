//
//  WishlistView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 28.05.25.
//

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
            if wishlistState.wishlistProducts.isEmpty && authManager.isLoggedIn {
                await wishlistState.fetchWishlistProducts()
            }
        }
        .refreshable {
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
                    ProductRowView(product: product) // Verwendung der konsistenten ProductRowView
                }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.plain)
    }

    private func deleteItems(at offsets: IndexSet) {
        let productsToDelete = offsets.map { wishlistState.wishlistProducts[$0] }
        
        for product in productsToDelete {
            wishlistState.toggleWishlistStatus(for: product)
        }
    }
}


