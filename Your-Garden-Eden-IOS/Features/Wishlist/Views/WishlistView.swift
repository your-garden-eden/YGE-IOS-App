// DATEI: WishlistView.swift
// PFAD: Features/Wishlist/Views/WishlistView.swift
// VERSION: 2.2 (FINAL & ANGEPASST)
// ZWECK: Hauptansicht der Wunschliste, angepasst an das globale Header-Schema mit Logo und Zurück-Button.

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var wishlistState: WishlistState
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var cartManager: CartAPIManager
    
    @State private var showingAuthSheet = false
    @State private var addingProductId: Int?

    var body: some View {
        ZStack {
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
        // KORREKTUR: Der explizite Navigationstitel wurde entfernt.
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await wishlistState.fetchWishlistFromServer()
        }
        .sheet(isPresented: $showingAuthSheet) {
            AuthContainerView(onDismiss: { self.showingAuthSheet = false })
        }
        .onChange(of: cartManager.state.errorMessage) { _, newValue in
            if newValue != nil {
                addingProductId = nil
            }
        }
        // KORREKTUR: Das Logo wird als primäres Toolbar-Element hinzugefügt.
        // Der alte Text-Titel wurde entfernt.
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
        // KORREKTUR: Der Zurück-Button wird wie befohlen hinzugefügt.
        .customBackButton()
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
                .buttonStyle(AppTheme.PrimaryButtonStyle())
                .padding(.top)
        }.padding()
    }

    private func productList(products: [WooCommerceProduct]) -> some View {
        List {
            ForEach(products) { product in
                ZStack {
                    NavigationLink(value: product) { EmptyView() }.opacity(0)
                    
                    WishlistRowView(
                        product: product,
                        isAddingToCart: addingProductId == product.id,
                        onAddToCart: {
                            Task {
                                addingProductId = product.id
                                await cartManager.addItem(productId: product.id, quantity: 1)
                                
                                if cartManager.state.errorMessage == nil {
                                    wishlistState.toggleWishlistStatus(for: product)
                                }
                                addingProductId = nil
                            }
                        }
                    )
                }
            }
            .onDelete(perform: deleteItems)
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
