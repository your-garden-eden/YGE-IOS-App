import SwiftUI

struct CategoryCardListView: View {
    let categories: [WooCommerceCategory]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppStyles.Spacing.large) {
                ForEach(categories) { category in
                    NavigationLink(value: category) {
                        // FIX: Die View sucht jetzt den korrekten Anzeigenamen und das Banner
                        // und übergibt beides an die Kind-View.
                        ShopCategoryCardView(
                            category: category,
                            displayName: findLabelFor(category: category)
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    /// Hilfsfunktion, um den korrekten, grammatikalisch sauberen Anzeigenamen
    /// aus unseren lokalen Daten zu finden.
    private func findLabelFor(category: WooCommerceCategory) -> String {
        // 1. Prüfen, ob es sich um eine Hauptkategorie handelt.
        if let mainItem = AppNavigationData.items.first(where: { $0.mainCategorySlug == category.slug }) {
            return mainItem.label
        }
        
        // 2. Wenn nicht, alle Unterkategorien durchsuchen.
        for item in AppNavigationData.items {
            if let subItems = item.subItems {
                if let subItem = subItems.first(where: { $0.linkSlug == category.slug }) {
                    return subItem.label
                }
            }
        }
        
        // 3. Als Fallback den Namen von der API verwenden, falls nichts gefunden wurde.
        return category.name.strippingHTML()
    }
}
