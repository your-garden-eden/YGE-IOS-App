//import Foundation
//import SwiftUI
//
//@MainActor
//class ProductCardViewModel: ObservableObject {
//    // --- KERN-ÄNDERUNG: Keine @Published-Properties für Preise mehr ---
//    // Die Preise werden einmal gesetzt und ändern sich nicht.
//    let productId: Int
//    let displayName: String
//    let imageURL: URL?
//    let displayPrice: String
//    let strikethroughPrice: String?
//
//    init(product: WooCommerceProduct) {
//        self.productId = product.id
//        self.displayName = product.name
//        self.imageURL = product.images.first?.src.asURL()
//        
//        // --- PREISBERECHNUNG DIREKT IM INITIALISIERER ---
//        
//        let currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"
//        
//        // Wir verwenden die neue, synchrone Funktion für alle Fälle.
//        // Sie verarbeitet HTML für variable Produkte und nutzt den Fallback für einfache Produkte.
//        let formattedPrice = PriceFormatter.formatPriceString(
//            from: product.priceHtml,
//            fallbackPrice: product.price,
//            currencySymbol: currencySymbol
//        )
//        
//        self.displayPrice = formattedPrice.display
//        self.strikethroughPrice = formattedPrice.strikethrough
//    }
//    
//    // Die asynchrone Funktion `calculatePrices()` wird nicht mehr benötigt und kann gelöscht werden.
//}
