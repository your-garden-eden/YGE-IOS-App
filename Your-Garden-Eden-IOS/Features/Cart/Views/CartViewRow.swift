// MARK: - CartRowView.swift

import SwiftUI

// Dies ist die finale, korrigierte Version, die die Compiler-Fehler behebt.
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
            productImage
                .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: AppStyles.Spacing.small) {
                Text(item.name)
                    // KORREKTUR: Font-Aufruf, um die 'Size'-Fehler zu beheben.
                    .font(AppFonts.montserrat(size: AppFonts.Size.headline, weight: .semibold))
                    .lineLimit(2)
                    .foregroundColor(AppColors.textHeadings)
                
                Text(item.totals?.lineTotal ?? "N/A")
                    .font(AppFonts.roboto(size: AppFonts.Size.subheadline, weight: .bold))
                    .foregroundColor(AppColors.price)
                
                Spacer(minLength: 4)
                
                quantityControl
            }
        }
        .padding(.vertical, AppStyles.Spacing.small)
        .onChange(of: item.quantity) { _, newServerQuantity in
            quantity = newServerQuantity
        }
    }
    
    @ViewBuilder
    private var productImage: some View {
        AsyncImage(url: item.images?.first?.thumbnail.asURL()) { phase in
            if let image = phase.image {
                image.resizable().aspectRatio(contentMode: .fill)
                    .cornerRadius(AppStyles.BorderRadius.medium).clipped()
            } else if phase.error != nil {
                 Rectangle().fill(AppColors.backgroundLightGray)
                    .overlay(Image(systemName: "photo.fill").foregroundColor(AppColors.textMuted.opacity(0.5)))
                    .cornerRadius(AppStyles.BorderRadius.medium)
            } else {
                ProgressView().frame(width: 80, height: 80)
            }
        }
    }
    
    private var quantityControl: some View {
        HStack(spacing: AppStyles.Spacing.small) {
            Button(action: {
                if quantity > 1 {
                    quantity -= 1
                    onQuantityChange(quantity)
                }
            }) {
                Image(systemName: "minus")
            }
            .buttonStyle(QuantityButtonStyle(color: AppColors.error))
            .disabled(quantity <= 1)
            
            Text("\(quantity)")
                // KORREKTUR: Korrekter Font-Aufruf mit `size`-Parameter.
                .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .medium))
                .frame(minWidth: 25, alignment: .center)
            
            Button(action: {
                quantity += 1
                onQuantityChange(quantity)
            }) {
                Image(systemName: "plus")
            }
            .buttonStyle(QuantityButtonStyle(color: AppColors.success))
        }
    }
}

// KORREKTUR: Der ButtonStyle wurde vereinfacht und korrigiert, um die 'Shape'-Fehler zu beheben.
fileprivate struct QuantityButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(color)
            .frame(width: 30, height: 30)
            .background(color.opacity(configuration.isPressed ? 0.25 : 0.1))
            .clipShape(Circle()) // Beschneidet die View zu einem Kreis.
            .overlay( // Legt einen Kreis-Rahmen darüber. Dies ist der korrekte Weg.
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
