import SwiftUI

struct QuantitySelectorView: View {
    @Binding var quantity: Int

    var body: some View {
        HStack(spacing: AppStyles.Spacing.medium) {
            Text("Menge:")
                .font(AppFonts.roboto(size: AppFonts.Size.headline, weight: .medium))
                .foregroundColor(AppColors.textHeadings)

            Spacer()

            Button {
                if quantity > 1 { quantity -= 1 }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(quantity > 1 ? AppColors.primaryDark : AppColors.textMuted.opacity(0.5))
            }
            .disabled(quantity <= 1)

            Text("\(quantity)")
                .font(AppFonts.roboto(size: AppFonts.Size.title2, weight: .semibold))
                .foregroundColor(AppColors.textBase)
                .frame(minWidth: 40, alignment: .center)

            Button {
                quantity += 1
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primaryDark)
            }
        }
        .padding(.vertical, AppStyles.Spacing.small)
        .buttonStyle(.plain)
    }
}
