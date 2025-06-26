// DATEI: WishlistView.swift
// PFAD: Features/Wishlist/Views/WishlistView.swift
// VERSION: 1.3 (INSTAND GESETZT)
// STATUS: Falscher UI-Aufruf korrigiert.

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var wishlistState: WishlistState
    @EnvironmentObject private var authManager: AuthManager
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
                    WishlistRowView(product: product)
                        .background(AppTheme.Colors.backgroundComponent)
                        .cornerRadius(AppTheme.Layout.BorderRadius.large)
                        // ===================================================================
                        // === BEGINN KORREKTUR #2                                         ===
                        // ===================================================================
                        // Der Aufruf wurde auf die korrekte, vollständige Koordinate geändert.
                        .appShadow(AppTheme.Shadows.small)
                        // ===================================================================
                        // === ENDE KORREKTUR #2                                           ===
                        // ===================================================================
                }
                .listRowBackground(AppTheme.Colors.backgroundPage)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            .onDelete(perform: deleteItemsFromSwipe)
            
            if !products.isEmpty {
                Section {
                    Button(action: { showingClearConfirmation = true }) {
                        HStack {
                            Spacer()
                            Label("Wunschliste leeren", systemImage: "trash")
                            Spacer()
                        }
                    }
                    .foregroundColor(AppTheme.Colors.error)
                }
                .listRowBackground(AppTheme.Colors.backgroundPage)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal)
        .id(wishlistState.sortOption)
    }
    
    private func deleteItemsFromSwipe(at offsets: IndexSet) {
        let productsToRemove = offsets.map { wishlistState.wishlistProducts[$0] }
        for product in productsToRemove {
            wishlistState.toggleWishlistStatus(for: product)
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
            Button("Anmelden oder Registrieren") {
                self.showingAuthSheet = true
            }
            .buttonStyle(AppTheme.PrimaryButtonStyle())
            .padding(.top)
        }.padding()
    }
}
