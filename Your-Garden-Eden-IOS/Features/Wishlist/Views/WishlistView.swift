// Path: Your-Garden-Eden-IOS/Features/Wishlist/WishlistView.swift

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var wishlistState: WishlistState
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var showingAuthSheet = false
    
    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()
            
            Group {
                if wishlistState.isLoading && wishlistState.wishlistProducts.isEmpty {
                    loadingView
                } else if wishlistState.wishlistProducts.isEmpty {
                    // Zeige unterschiedliche Ansichten für Gäste und eingeloggte User
                    if authManager.isLoggedIn {
                        emptyWishlistView
                    } else {
                        loginPromptView
                    }
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
        .refreshable {
            await wishlistState.fetchWishlistFromServer()
        }
        .sheet(isPresented: $showingAuthSheet) {
            AuthContainerView(onDismiss: { self.showingAuthSheet = false })
                .environmentObject(authManager)
        }
    }
    
    // MARK: - Subviews

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
                .font(.system(size: 60)).foregroundColor(AppColors.textMuted.opacity(0.7))
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
                .font(.system(size: 60)).foregroundColor(AppColors.textMuted.opacity(0.7))
            Text("Anmelden für Wunschliste")
                .font(AppFonts.montserrat(size: AppFonts.Size.h5, weight: .semibold))
                .foregroundColor(AppColors.textHeadings)
            Text("Um deine Wunschliste geräteübergreifend zu speichern, melde dich bitte an.")
                .font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Anmelden oder Registrieren") {
                self.showingAuthSheet = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top)
        }
        .padding()
    }

    private func productList(products: [WooCommerceProduct]) -> some View {
        List {
            ForEach(products) { product in
                ZStack {
                    NavigationLink(value: product) { EmptyView() }.opacity(0)
                    WishlistRowView(product: product)
                }
            }
            .onDelete(perform: deleteItems)
            .listRowBackground(AppColors.backgroundPage)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: AppStyles.Spacing.small, leading: 0, bottom: AppStyles.Spacing.small, trailing: 0))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, AppStyles.Spacing.medium)
    }

    private func deleteItems(at offsets: IndexSet) {
        let productsToDelete = offsets.map { wishlistState.wishlistProducts[$0] }
        for product in productsToDelete {
            wishlistState.toggleWishlistStatus(for: product)
        }
    }
}
