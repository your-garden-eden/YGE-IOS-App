// DATEI: WishlistView.swift
// PFAD: Features/Wishlist/Views/WishlistView.swift
// VERSION: 2.0 (FINAL & KORRIGIERT)
// ZWECK: Die Hauptansicht zur Darstellung der Wunschliste des Benutzers.

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var wishlistState: WishlistState
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var showingAuthSheet = false
    
    var body: some View {
        ZStack {
            // KORREKTUR: Verwendet die zentrale AppTheme-Struktur.
            AppTheme.Colors.backgroundPage.ignoresSafeArea()
            
            Group {
                if wishlistState.isLoading && wishlistState.wishlistProducts.isEmpty {
                    loadingView
                } else if wishlistState.wishlistProducts.isEmpty {
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
                    // KORREKTUR: Verwendet die zentrale AppTheme-Struktur.
                    .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.headline, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textHeadings)
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

    private var loadingView: some View {
        VStack(spacing: AppTheme.Layout.Spacing.medium) {
            ProgressView().tint(AppTheme.Colors.primary)
            Text("Lade Wunschliste...")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textMuted)
        }
    }

    private var emptyWishlistView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textMuted.opacity(0.7))
            
            Text("Deine Wunschliste ist leer")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h5, weight: .bold))
                .foregroundColor(AppTheme.Colors.textHeadings)
            
            Text("Füge Produkte hinzu, indem du auf das Herz-Symbol tippst.")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }.padding()
    }

    private var loginPromptView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textMuted.opacity(0.7))
            
            Text("Anmelden für Wunschliste")
                .font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h5, weight: .bold))
                .foregroundColor(AppTheme.Colors.textHeadings)
            
            Text("Um deine Wunschliste geräteübergreifend zu speichern, melde dich bitte an.")
                .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body))
                .foregroundColor(AppTheme.Colors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Anmelden oder Registrieren") { self.showingAuthSheet = true }
                // KORREKTUR: Verwendet die zentrale AppTheme-Struktur.
                .buttonStyle(AppTheme.PrimaryButtonStyle())
                .padding(.top)
        }.padding()
    }

    private func productList(products: [WooCommerceProduct]) -> some View {
        List {
            ForEach(products) { product in
                ZStack {
                    NavigationLink(value: product) { EmptyView() }.opacity(0)
                    // Verwendet die neue, saubere Row-Komponente.
                    WishlistRowView(product: product)
                }
            }
            .onDelete(perform: deleteItems)
            // KORREKTUR: Verwendet die zentrale AppTheme-Struktur.
            .listRowBackground(AppTheme.Colors.backgroundPage)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: AppTheme.Layout.Spacing.small, leading: 0, bottom: AppTheme.Layout.Spacing.small, trailing: 0))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, AppTheme.Layout.Spacing.medium)
    }

    private func deleteItems(at offsets: IndexSet) {
        let productsToDelete = offsets.map { wishlistState.wishlistProducts[$0] }
        for product in productsToDelete {
            wishlistState.toggleWishlistStatus(for: product)
        }
    }
}
