import SwiftUI

struct SubCategoryRow: View {
    let subCategory: DisplayableSubCategory

    var body: some View {
        HStack(spacing: 15) {
            // Die Icon-Logik ist unverändert.
            if let iconName = subCategory.iconFilename,
               let uiImage = UIImage(named: iconName) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .background(AppColors.backgroundLightGray)
                    .clipShape(Circle())
                
            } else {
                
                Image(systemName: "tag.fill")
                    .foregroundColor(AppColors.textMuted)
                    .frame(width: 40, height: 40)
                    .background(AppColors.backgroundLightGray)
                    .clipShape(Circle())
            }
            
            // Der Name der Unterkategorie.
            Text(subCategory.label)
                // UPDATED: Nutzt den nativen "body" Stil.
                // Für eine etwas stärkere Gewichtung könnte man .font(.body.weight(.medium)) verwenden.
                .font(.body)
                .foregroundStyle(AppColors.textBase)
            
            Spacer()
            
            // Der Chevron bleibt unverändert.
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textMuted.opacity(0.7))
        }
        .padding(.vertical, 8)
        .background(.clear)
    }
}
