import SwiftUI

struct CartView: View {
    
    // Das ViewModel wird direkt mit @StateObject initialisiert und ist daher nicht optional.
    @StateObject private var viewModel = CartViewModel()

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
                    CartRowView(item: item) { newQuantity in
                        viewModel.updateQuantity(for: item, newQuantity: newQuantity)
                    }
                    .listRowBackground(AppColors.backgroundComponent)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) { viewModel.removeItem(item) } label: {
                            Label("Löschen", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            // KORREKTUR 1: Sicherer Zugriff auf `viewModel.totals`.
            // Dies behebt den Fehler "Value of optional type 'CartViewModel?' must be unwrapped".
            // Wir prüfen, ob 'totals' einen Wert hat, bevor wir die View erstellen.
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
                Text(totals.totalPrice ?? "N/A").font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                    .foregroundColor(AppColors.textBase)
            }
            HStack {
                Text("Versand").font(AppFonts.roboto(size: AppFonts.Size.body))
                    .foregroundColor(AppColors.textMuted)
                Spacer()
                Text(totals.totalShipping ?? "Wird berechnet").font(AppFonts.roboto(size: AppFonts.Size.body, weight: .medium))
                    .foregroundColor(AppColors.textBase)
            }
            
            Divider().padding(.vertical, AppStyles.Spacing.xSmall)
            
            HStack {
                Text("Gesamt")
                    .font(AppFonts.montserrat(size: AppFonts.Size.title3, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
                Spacer()
                Text("\(totals.currencySymbol ?? "")\(totals.totalPrice ?? "0,00")")
                    .font(AppFonts.montserrat(size: AppFonts.Size.title3, weight: .bold))
                    .foregroundColor(AppColors.textHeadings)
            }
            
            Button(action: { print("Zur Kasse") }) {
                Text("Zur Kasse")
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .bold))
                    .foregroundColor(AppColors.textOnPrimary)
                    .frame(maxWidth: .infinity).padding()
                    .background(AppColors.primary).cornerRadius(AppStyles.BorderRadius.large)
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
        }
        .padding()
    }
}

