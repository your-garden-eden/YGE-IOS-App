// DATEI: WishlistView.swift
// PFAD: Features/Wishlist/Views/WishlistView.swift
// VERSION: KEHRTWENDE 1.0 (ANGEPASST)

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var wishlistState: WishlistState
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var cartManager: CartAPIManager
    @Environment(\.selectedTab) private var selectedTab

    @State private var showingAuthSheet = false
    @State private var showingClearConfirmation = false

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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .refreshable { await wishlistState.fetchWishlistFromServer() }
        .sheet(isPresented: $showingAuthSheet) { AuthContainerView(onDismiss: { self.showingAuthSheet = false }) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    selectedTab.wrappedValue = 1
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Zurück zum Shop")
                    }
                    .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primaryDark)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent").resizable().scaledToFit().frame(height: 150)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sortieren nach", selection: $wishlistState.sortOption) {
                        ForEach(WishlistSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.title3).foregroundColor(AppTheme.Colors.primaryDark)
                }
                .disabled(wishlistState.wishlistProducts.isEmpty)
            }
        }
        .alert("Wunschliste leeren?", isPresented: $showingClearConfirmation) {
            Button("Löschen", role: .destructive) {
                wishlistState.clearWishlist()
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Möchtest du wirklich alle Artikel von deiner Wunschliste entfernen?")
        }
    }

    private func productList(products: [WooCommerceProduct]) -> some View {
        List {
            ForEach(products) { product in
                NavigationLink(value: product) {
                    // --- BEGINN MODIFIKATION ---
                    // Der Aufruf der WishlistRowView erfolgt nun ohne den onDelete-Parameter.
                    WishlistRowView(product: product)
                    // --- ENDE MODIFIKATION ---
                        .padding()
                        .background(AppTheme.Colors.backgroundComponent)
                        .cornerRadius(AppTheme.Layout.BorderRadius.large)
                        .appShadow(AppTheme.Shadows.small)
                }
                .buttonStyle(.plain)
                .listRowBackground(AppTheme.Colors.backgroundPage)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: AppTheme.Layout.Spacing.small, leading: 0, bottom: AppTheme.Layout.Spacing.small, trailing: 0))
            }
            .onDelete(perform: deleteItemsFromSwipe)
            
            Section {
                Button(action: {
                    showingClearConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "trash.fill")
                        Text("Wunschliste leeren")
                        Spacer()
                    }
                }
                .foregroundColor(AppTheme.Colors.error)
                .padding()
            }
            .listRowBackground(AppTheme.Colors.backgroundPage)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal, AppTheme.Layout.Spacing.medium)
        .id(wishlistState.sortOption)
    }
    
    // --- BEGINN MODIFIKATION ---
    // Die 'delete(product:)' Funktion ist nun redundant und wird entfernt.
    /*
    private func delete(product: WooCommerceProduct) {
        wishlistState.toggleWishlistStatus(for: product)
    }
    */
    
    /// Funktion, die durch die Wisch-Geste aufgerufen wird.
    private func deleteItemsFromSwipe(at offsets: IndexSet) {
        let productsToRemove = offsets.map { wishlistState.wishlistProducts[$0] }
        for product in productsToRemove {
            // Die Logik wird direkt hier aufgerufen.
            wishlistState.toggleWishlistStatus(for: product)
        }
    }
    // --- ENDE MODIFIKATION ---

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
            Image(systemName: "heart.slash.fill").font(.system(size: 60)).foregroundColor(AppTheme.Colors.textMuted.opacity(0.7))
            Text("Deine Wunschliste ist leer").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h5, weight: .bold)).foregroundColor(AppTheme.Colors.textHeadings)
            Text("Füge Produkte hinzu, indem du auf das Herz-Symbol tippst.").font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)).foregroundColor(AppTheme.Colors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
        }.padding()
    }

    private var loginPromptView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark.fill").font(.system(size: 60)).foregroundColor(AppTheme.Colors.textMuted.opacity(0.7))
            Text("Anmelden für Wunschliste").font(AppTheme.Fonts.montserrat(size: AppTheme.Fonts.Size.h5, weight: .bold)).foregroundColor(AppTheme.Colors.textHeadings)
            Text("Um deine Wunschliste geräteübergreifend zu speichern, melde dich bitte an.").font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)).foregroundColor(AppTheme.Colors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
            Button("Anmelden oder Registrieren") { self.showingAuthSheet = true }.buttonStyle(AppTheme.PrimaryButtonStyle()).padding(.top)
        }.padding()
    }
}
