import SwiftUI

struct SubCategoryRow: View {
    let subCategory: DisplayableSubCategory

    var body: some View {
        HStack {
            Text(subCategory.label).font(AppFonts.montserrat(size: AppFonts.Size.body, weight: .semibold)).foregroundColor(AppColors.textHeadings)
            Spacer()
            Text("\(subCategory.count)").font(AppFonts.roboto(size: AppFonts.Size.body, weight: .regular)).foregroundColor(AppColors.textMuted)
            Image(systemName: "chevron.right").foregroundColor(AppColors.textMuted.opacity(0.7))
        }
        .padding()
        .background(AppColors.backgroundComponent)
        .cornerRadius(AppStyles.BorderRadius.medium)
        .appShadow(AppStyles.Shadows.small)
    }
}
