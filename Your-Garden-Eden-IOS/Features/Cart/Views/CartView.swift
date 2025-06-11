// Features/Cart/Views/CartView.swift
import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel() // Eigenständiger ViewModel für die CartView
    @ObservedObject private var cartAPIManager = CartAPIManager.shared // Für direkten Zugriff auf Ladezustände/Fehler

    @State private var showingClearCartAlert = false

    var body: some View {
        NavigationStack {
            Group {
                // Ladezustand
                if cartAPIManager.isLoading && viewModel.cartItems.isEmpty {
                    ProgressView("Lade Warenkorb...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppColors.backgroundPage.ignoresSafeArea())
                }
                // Fehlerzustand
                else if let errorMessage = cartAPIManager.errorMessage, !errorMessage.isEmpty, viewModel.cartItems.isEmpty {
                     VStack(spacing: AppStyles.Spacing.medium) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40)).foregroundColor(AppColors.error)
                        Text("Fehler im Warenkorb").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .semibold))
                        Text(errorMessage).font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center).padding(.horizontal)
                        Button("Erneut versuchen") { Task { await viewModel.refreshCart() } }
                            .buttonStyle(.borderedProminent).tint(AppColors.primary).padding(.top)
                    }
                    .padding(AppStyles.Spacing.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.backgroundPage.ignoresSafeArea())
                }
                // Leerzustand
                else if viewModel.cartItems.isEmpty && !cartAPIManager.isLoading {
                    VStack(spacing: AppStyles.Spacing.medium) {
                        Image(systemName: "cart.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.textMuted)
                        Text("Dein Warenkorb ist leer")
                            .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .semibold))
                        Text("Stöbere durch unseren Shop und füge tolle Produkte hinzu!")
                            .font(AppFonts.roboto(size: AppFonts.Size.body))
                            .foregroundColor(AppColors.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(AppStyles.Spacing.large)
                    .background(AppColors.backgroundPage.ignoresSafeArea())
                }
                // Warenkorb mit Artikeln
                else {
                    List {
                        ForEach(viewModel.cartItems) { item in
                            CartItemRow(item: item, viewModel: viewModel)
                        }
                        .onDelete(perform: deleteItems)

                        Section {
                             if let totals = viewModel.cartTotals {
                                totalsView(totals: totals, currencySymbol: viewModel.currencySymbol)
                            }
                        } footer: {
                            if !viewModel.cartItems.isEmpty {
                                Button("Zur Kasse") {
                                    print("Zur Kasse gedrückt - Checkout-Logik hier implementieren")
                                    // Hier würde die Navigation zum Checkout-Flow starten
                                }
                                .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .semibold))
                                .foregroundColor(AppColors.textOnPrimary)
                                .padding(EdgeInsets(top: AppStyles.Spacing.small, leading: AppStyles.Spacing.large, bottom: AppStyles.Spacing.small, trailing: AppStyles.Spacing.large))
                                .frame(maxWidth: .infinity)
                                .background(AppColors.primary)
                                .cornerRadius(AppStyles.BorderRadius.medium)
                                .listRowInsets(EdgeInsets(top: AppStyles.Spacing.medium, leading: 0, bottom: AppStyles.Spacing.medium, trailing: 0))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(AppColors.backgroundPage)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await viewModel.refreshCart()
                    }
                }
            }
            .navigationTitle("Warenkorb")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPage.opacity(0.8), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.cartItems.isEmpty {
                        Button {
                            showingClearCartAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(AppColors.error)
                        }
                        .help("Warenkorb leeren")
                    }
                }
            }
            .alert("Warenkorb leeren?", isPresented: $showingClearCartAlert) {
                Button("Leeren", role: .destructive) { viewModel.clearCart() }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Möchtest du wirklich alle Artikel aus deinem Warenkorb entfernen?")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        let itemsToDeleteKeys = offsets.map { viewModel.cartItems[$0].key }
        for key in itemsToDeleteKeys {
            viewModel.removeItem(itemKey: key)
        }
    }

    @ViewBuilder
    private func totalsView(totals: WooCommerceStoreCartTotals, currencySymbol: String) -> some View {
        VStack(alignment: .trailing, spacing: AppStyles.Spacing.xSmall) {
            HStack { Text("Zwischensumme Artikel"); Spacer(); Text("\(currencySymbol)\(String(describing: totals.totalItems))") }
                .font(AppFonts.roboto(size: AppFonts.Size.body))
            
            if let shippingTotalString = totals.totalShipping, let shippingTotalValue = Double(shippingTotalString), shippingTotalValue > 0 {
                HStack { Text("Versand"); Spacer(); Text("\(currencySymbol)\(shippingTotalString)") }
                    .font(AppFonts.roboto(size: AppFonts.Size.body))
            }
            
            if let discountTotalString = totals.totalDiscount, let discountTotalValue = Double(discountTotalString), discountTotalValue > 0 {
                 HStack { Text("Rabatt"); Spacer(); Text("-\(currencySymbol)\(discountTotalString)") }
                    .font(AppFonts.roboto(size: AppFonts.Size.body)).foregroundColor(AppColors.success)
            }
            
            Divider().padding(.vertical, AppStyles.Spacing.xxSmall)
            
            HStack {
                Text("Gesamtsumme").font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold))
                Spacer()
                Text("\(currencySymbol)\(totals.totalPrice)")
                    .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold)).foregroundColor(AppColors.primaryDark)
            }
        }
        .padding(.vertical, AppStyles.Spacing.small)
    }
}
