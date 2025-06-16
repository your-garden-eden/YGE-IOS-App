import SwiftUI

struct ErrorStateView: View {
    let message: String
    var body: some View {
        VStack(spacing: AppStyles.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundColor(AppColors.error)
            Text(message).font(AppFonts.montserrat(size: AppFonts.Size.body)).foregroundColor(AppColors.textMuted).multilineTextAlignment(.center).padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
struct SuccessBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.success)
            .foregroundColor(AppColors.textOnPrimary)
            .cornerRadius(AppStyles.BorderRadius.large)
            .appShadow(AppStyles.Shadows.medium)
            .padding(.horizontal)
    }
}

struct ErrorBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.error)
            .foregroundColor(AppColors.textOnPrimary)
            .cornerRadius(AppStyles.BorderRadius.large)
            .appShadow(AppStyles.Shadows.medium)
            .padding(.horizontal)
    }
}
