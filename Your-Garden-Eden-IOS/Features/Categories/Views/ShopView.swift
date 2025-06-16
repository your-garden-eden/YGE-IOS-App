import SwiftUI

struct ShopView: View {
    
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    var body: some View {
        ZStack {
            AppColors.backgroundPage.ignoresSafeArea()

            if categoryViewModel.isLoading {
                ProgressView().tint(AppColors.primary)
            } else if let errorMessage = categoryViewModel.errorMessage {
                ErrorStateView(message: errorMessage)
            } else {
                // FIX: Die Liste wird jetzt direkt hier mit Überschriften aufgebaut.
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppStyles.Spacing.large) {
                        ForEach(categoryViewModel.topLevelCategories) { category in
                            // Jede Kategorie bekommt eine eigene Sektion mit Überschrift.
                            VStack(alignment: .leading, spacing: AppStyles.Spacing.medium) {
                                Text(findLabelFor(category: category))
                                    .font(AppFonts.montserrat(size: AppFonts.Size.h3, weight: .bold))
                                    .foregroundColor(AppColors.textHeadings)
                                
                                NavigationLink(value: category) {
                                    ShopCategoryCardView(
                                        category: category,
                                        displayName: findLabelFor(category: category)
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await categoryViewModel.fetchTopLevelCategories()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo_your_garden_eden_transparent")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
    }
    
    private func findLabelFor(category: WooCommerceCategory) -> String {
        return AppNavigationData.items.first { $0.mainCategorySlug == category.slug }?.label ?? category.name.strippingHTML()
    }
}
