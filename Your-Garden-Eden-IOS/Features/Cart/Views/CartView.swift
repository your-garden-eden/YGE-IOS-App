//
//  CartView.swift
//  Your-Garden-Eden-IOS
//
//  Created by ... // Dein Erstellungsdatum
//

import SwiftUI

struct CartView: View {
    
    @StateObject private var viewModel = CartViewModel()
    
    // Greift auf den in EnvironmentValues+Extensions.swift definierten Key zu.
    @Environment(\.selectedTab) private var selectedTab

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundPage.ignoresSafeArea()

                VStack {
                    if viewModel.items.isEmpty && !viewModel.isLoading {
                        emptyCartView
                    } else {
                        cartContentView
                    }
                }
                .overlay {
                    if viewModel.isLoading && viewModel.items.isEmpty {
                        ProgressView("Lade Warenkorb...")
                            .tint(AppColors.primary)
                    }
                }
            }
            .navigationTitle("Warenkorb")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .principal) {
                     Text("Warenkorb")
                         .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                         .foregroundColor(AppColors.textHeadings)
                 }
            }
            .task {
                await viewModel.refreshCart()
            }
            .refreshable {
                await viewModel.refreshCart()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    private var cartContentView: some View {
        VStack {
            List {
                ForEach(viewModel.items) { item in
                    VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                        CartRowView(item: item) { newQuantity in
                            viewModel.updateQuantity(for: item, newQuantity: newQuantity)
                        }
                        
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.removeItem(item)
                            }
                        } label: {
                            Label("Entfernen", systemImage: "trash")
                                .font(AppFonts.roboto(size: AppFonts.Size.caption))
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, AppStyles.Spacing.small)
                    .listRowBackground(AppColors.backgroundComponent)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.removeItem(item)
                            }
                        } label: {
                            Label("Löschen", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            if let totals = viewModel.totals {
                cartTotalsView(totals: totals)
            }
        }
    }
    
    private func cartTotalsView(totals: Totals) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            HStack {
                Text("Zwischensumme").font(AppFonts.roboto(size: AppFonts.Size.body))
                    .foregroundColor(AppColors.textMuted)
                Spacer()
                // Greift auf die neue, berechnete Eigenschaft im Totals-Modell zu.
                Text(totals.totalItemsPriceFormatted).font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                    .foregroundColor(AppColors.textBase)
            }
            HStack {
                Text("Versand").font(AppFonts.roboto(size: AppFonts.Size.body))
                    .foregroundColor(AppColors.textMuted)
                Spacer()
                // Greift auf die neue, berechnete Eigenschaft im Totals-Modell zu.
                Text(totals.totalShippingFormatted).font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                    .foregroundColor(AppColors.textBase)
            }
            
            Divider().padding(.vertical, AppStyles.Spacing.xSmall)
            
            HStack {
                Text("Gesamt")
                    .font(AppFonts.montserrat(size: AppFonts.Size.title3, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
                Spacer()
                // Greift auf die neue, berechnete Eigenschaft im Totals-Modell zu.
                Text(totals.totalPriceFormatted)
                    .font(AppFonts.montserrat(size: AppFonts.Size.title3, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
            }
            
            Button(action: { print("Zur Kasse") }) {
                Text("Zur Kasse")
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                    .foregroundColor(AppColors.textOnPrimary)
                    .frame(maxWidth: .infinity).padding()
                    .background(AppColors.primary).cornerRadius(AppStyles.BorderRadius.large)
                    .appShadow(AppStyles.Shadows.small)
            }
            .padding(.top, AppStyles.Spacing.small)
        }
        .padding()
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.large)
        .padding()
    }
    
    @ViewBuilder
    private var emptyCartView: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "cart.fill")
                .font(.system(size: 60)).foregroundColor(AppColors.primary.opacity(0.5))
            Text("Dein Warenkorb ist leer")
                .font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold))
                .foregroundColor(AppColors.textHeadings)
            Text("Füge Produkte hinzu, um sie hier zu sehen.")
                .font(AppFonts.roboto(size: AppFonts.Size.body))
                .foregroundColor(AppColors.textMuted).multilineTextAlignment(.center)
            
            Button(action: {
                // Wechselt zum ersten Tab (Shop) durch Schreiben in die Environment-Bindung.
                selectedTab.wrappedValue = 0
            }) {
                Text("Weiter einkaufen")
                    .font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .bold))
                    .padding(.horizontal, 40)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
            .controlSize(.large)
            .padding(.top)
        }
        .padding()
    }
}
