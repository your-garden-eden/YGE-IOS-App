// Path: Your-Garden-Eden-IOS/Features/Cart/CartView.swift

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartAPIManager
    @Environment(\.selectedTab) private var selectedTab
    @State private var isShowingAuthSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPage.ignoresSafeArea()

                if cartManager.state.isLoading && cartManager.state.items.isEmpty {
                    initialLoadingView
                } else if cartManager.state.items.isEmpty {
                    emptyCartView
                } else {
                    cartContentView
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
            .refreshable {
                await cartManager.getCart()
            }
        }
    }
    
    @ViewBuilder
    private var cartContentView: some View {
        ScrollView {
            LazyVStack(spacing: AppStyles.Spacing.medium) {
                ForEach(cartManager.state.items) { item in
                    CartRowView(item: item)
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            if let totals = cartManager.state.totals {
                cartTotalsView(totals: totals)
            }
        }
    }
    
    private func cartTotalsView(totals: Totals) -> some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            if let error = cartManager.state.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(AppColors.error)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Text("Gesamt")
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                Spacer()
                Text(totals.totalPriceFormatted)
                    .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .bold))
            }
            
            NavigationLink(value: CheckoutView()) {
                 Text("Zur Kasse")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(cartManager.state.items.isEmpty)
        }
        .padding()
        .background(.regularMaterial)
    }

    private var initialLoadingView: some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            ProgressView().tint(AppColors.primary)
            Text("Lade Warenkorb...").foregroundColor(AppColors.textMuted)
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "cart").font(.system(size: 60, weight: .light)).foregroundColor(AppColors.textMuted)
            Text("Dein Warenkorb ist leer").font(AppFonts.montserrat(size: AppFonts.Size.title2, weight: .bold))
            Button("Weiter einkaufen") { self.selectedTab.wrappedValue = 1 } // Navigiert zum Shop-Tab
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top)
        }
        .padding()
    }
}
