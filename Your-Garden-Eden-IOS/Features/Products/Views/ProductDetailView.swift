// Features/Products/Views/ProductDetailView.swift
import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var wishlistState: WishlistState // Hinzufügen
    @EnvironmentObject var authManager: FirebaseAuthManager // Für Login-Aufforderung

    @StateObject private var viewModel: ProductDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedImageIndex: Int = 0
    @State private var showingAuthSheet = false // Für Login-Aufforderung

    init(productSlug: String, initialProductData: WooCommerceProduct? = nil) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(productSlug: productSlug, initialProductData: initialProductData))
    }
    
    var body: some View {
        ScrollView {
            // ... (Lade- & Fehlerzustand)
            if let product = viewModel.product {
                // ... (Produktbildgalerie)
                
                VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                    HStack(alignment: .top) { // HStack für Name und Herz-Button
                        Text(product.name)
                            .font(AppFonts.montserrat(size: AppFonts.Size.h2, weight: .bold))
                            .foregroundColor(AppColors.textHeadings)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer() // Drückt Herz-Button nach rechts

                        Button {
                            if authManager.user != nil {
                                wishlistState.toggleWishlistStatus(for: product.id)
                            } else {
                                showingAuthSheet = true
                            }
                        } label: {
                            Image(systemName: wishlistState.isProductInWishlist(productId: product.id) ? "heart.fill" : "heart")
                                .font(.title) // Etwas größer hier
                                .foregroundColor(wishlistState.isProductInWishlist(productId: product.id) ? AppColors.wishlistIcon : AppColors.textMuted)
                                .padding(AppStyles.Spacing.xSmall)
                        }
                    }
                    // ... (Rest der Produktinfos: Preis, Beschreibung, Varianten etc.)
                }
                // ...
            } else {
                // ... (Fallback, wenn Produkt nil)
            }
        }
        // ... (Rest der Modifier: .background, .navigationTitle etc.)
        .sheet(isPresented: $showingAuthSheet) {
            AuthContainerView(onDismiss: { showingAuthSheet = false })
                .environmentObject(authManager)
        }
    }
    // ... (productImageGallery etc.)
}
