//
//  SubCategoryRow.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 05.06.25.
//


import SwiftUI

struct SubCategoryRow: View {
    let subCategory: DisplayableSubCategory

    var body: some View {
        HStack(spacing: 15) {
            if let iconName = subCategory.iconFilename {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .background(AppColors.backgroundLightGray)
                    .clipShape(Circle())
            } else {
                // Fallback-Icon
                Image(systemName: "tag.fill")
                    .frame(width: 40, height: 40)
                    .background(AppColors.backgroundLightGray)
                    .clipShape(Circle())
                    .foregroundStyle(AppColors.textMuted)
            }
            
            Text(subCategory.label)
                .font(.headline)
                .foregroundStyle(AppColors.textBase)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}