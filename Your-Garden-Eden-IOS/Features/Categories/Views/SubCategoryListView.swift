import SwiftUI

struct SubCategoryListView: View {
    @StateObject private var viewModel: SubCategoryListViewModel

    init(selectedMainCategoryAppItem: AppNavigationItem, parentWooCommerceCategoryID: Int) {
        _viewModel = StateObject(wrappedValue: SubCategoryListViewModel(
            mainCategoryAppItem: selectedMainCategoryAppItem,
            parentWooCommerceCategoryID: parentWooCommerceCategoryID
        ))
    }

    var body: some View {
        subCategorySelectionList
            .navigationTitle(viewModel.mainCategoryAppItem.label)
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColors.backgroundPage.ignoresSafeArea())
    }

    private var subCategorySelectionList: some View {
        List {
            ForEach(viewModel.displayableSubCategories) { subCat in
                // HINWEIS: Dieser `NavigationLink` würde eine Modernisierung auf `value:` benötigen.
                NavigationLink(value: subCat) {
                    SubCategoryRow(subCategory: subCat)
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: AppStyles.Spacing.xSmall, leading: 0, bottom: AppStyles.Spacing.xSmall, trailing: 0))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .padding(.horizontal)
    }
}
