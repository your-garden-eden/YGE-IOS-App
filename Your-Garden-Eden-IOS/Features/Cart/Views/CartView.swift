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

// Dedizierte View für die Warenkorb-Zeile
struct CartRowView: View {
    let item: Item
    let onQuantityChange: (Int) -> Void

    @State private var quantity: Int

    init(item: Item, onQuantityChange: @escaping (Int) -> Void) {
        self.item = item
        self.onQuantityChange = onQuantityChange
        _quantity = State(initialValue: item.quantity)
    }

    var body: some View {
        HStack(spacing: AppStyles.Spacing.medium) {
            // KORREKTUR 2: Das überflüssige '?' nach 'thumbnail' wurde entfernt.
            // Dies behebt den Fehler "Cannot use optional chaining on non-optional value".
            AsyncImage(url: item.images?.first?.thumbnail.asURL()) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80).cornerRadius(AppStyles.BorderRadius.medium).clipped()
                } else if phase.error != nil {
                     Rectangle().fill(AppColors.backgroundLightGray).frame(width: 80, height: 80).cornerRadius(AppStyles.BorderRadius.medium) // Fehler-Platzhalter
                } else {
                    ProgressView().frame(width: 80, height: 80) // Lade-Platzhalter
                }
            }

            VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
                Text(item.name)
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold)).lineLimit(2)
                    .foregroundColor(AppColors.textHeadings)
                Text(item.totals?.lineTotal ?? "N/A")
                    .font(AppFonts.roboto(size: AppFonts.Size.subheadline, weight: .bold)).foregroundColor(AppColors.price)
                
                Stepper("Menge: \(quantity)", value: $quantity, in: 1...100)
                    .onChange(of: quantity) { _, newValue in
                        onQuantityChange(newValue)
                    }
                    .font(AppFonts.roboto(size: AppFonts.Size.caption))
            }
        }
        .padding(.vertical, AppStyles.Spacing.small)
    }
}
