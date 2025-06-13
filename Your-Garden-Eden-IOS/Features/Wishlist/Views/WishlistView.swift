// Dateiname: WishlistView.swift

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var wishlistState: WishlistState
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ZStack {
            // Hintergrundfarbe aus Ihrem Design-System
            AppColors.backgroundPage.ignoresSafeArea()
            
            // Hauptinhalt
            Group {
                if wishlistState.isLoading && wishlistState.wishlistProducts.isEmpty {
                    loadingView
                } else if !authManager.isLoggedIn {
                    loginPromptView
                } else if wishlistState.wishlistProducts.isEmpty {
                    emptyWishlistView
                } else {
                    productList(products: wishlistState.wishlistProducts)
                }
            }
        }
        .navigationTitle("Wunschliste")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Wunschliste")
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
            }
        }
        // Der .task-Block wird entfernt, da WishlistState sich selbst aktualisiert.
        .refreshable {
            // Bei Pull-to-Refresh die Daten vom Server neu laden.
            await wishlistState.fetchWishlistFromServer()
        }
    }
    
    // MARK: - Gestylte Subviews

    private var loadingView: some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            ProgressView().tint(AppColors.primary)
            Text("Lade Wunschliste...")
                .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .regular))
                .foregroundColor(AppColors.textMuted)
        }
    }

    private var emptyWishlistView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textMuted.opacity(0.7))
            Text("Deine Wunschliste ist leer")
                .font(AppFonts.montserrat(size: AppFonts.Size.h5, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            Text("Füge Produkte hinzu, indem du auf das Herz-Symbol tippst.")
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    private var loginPromptView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textMuted.opacity(0.7))
            Text("Melde dich an")
                .font(AppFonts.montserrat(size: AppFonts.Size.h5, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            Text("Um deine Wunschliste zu sehen und zu speichern, melde dich bitte an.")
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Optional: Ein Button, der zur Profil-Seite navigiert
            // (Benötigt eine Navigation-Logik, die wir später einbauen können)
        }
        .padding()
    }

    private func productList(products: [WooCommerceProduct]) -> some View {
        List {
            ForEach(products) { product in
                // Verwenden der neuen, gestylten WishlistRowView
                NavigationLink(value: product) {
                    WishlistRowView(product: product)
                }
            }
            .onDelete(perform: deleteItems)
            .listRowBackground(AppColors.backgroundPage) // Passt den Hintergrund jeder Zelle an
            .listRowSeparator(.hidden) // Versteckt die Standard-Trennlinien
            .padding(.vertical, AppStyles.Spacing.xSmall) // Fügt Abstand zwischen den Karten hinzu
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden) // Lässt den Listenhintergrund transparent werden
        .padding(.horizontal, AppStyles.Spacing.medium)
    }

    private func deleteItems(at offsets: IndexSet) {
        let productsToDelete = offsets.map { wishlistState.wishlistProducts[$0] }
        for product in productsToDelete {
            wishlistState.toggleWishlistStatus(for: product)
        }
    }
}
