//
//  ErrorStateView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 14.06.25.
//


// Path: Your-Garden-Eden-IOS/Features/Common/Views/ErrorStateView.swift

import SwiftUI

struct ErrorStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: AppStyles.Spacing.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColors.error.opacity(0.7))
            
            Text("Ein Fehler ist aufgetreten")
                .font(AppFonts.montserrat(size: AppFonts.Size.h5, weight: .bold))
                .foregroundColor(AppColors.textHeadings)
            
            Text(message)
                .font(AppFonts.roboto(size: AppFonts.Size.body))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}