import Foundation
import SwiftUI

@MainActor
class ProductCardViewModel: ObservableObject {
    let productId: Int
    let displayName: String
    let imageURL: URL?
    
    // Diese Eigenschaft wird jetzt asynchron gefüllt.
    @Published var displayPrice: String = "..." // Platzhalter
    @Published var strikethroughPrice: String?

    private let product: WooCommerceProduct // Wir speichern das Produkt für die async-Funktion

    init(product: WooCommerceProduct) {
        self.product = product
        self.productId = product.id
        self.displayName = product.name
        self.imageURL = product.images.first?.src.asURL()
    }
    
    // --- NEU: Eine asynchrone Setup-Funktion ---
    /// Berechnet die Preise sicher nach der Initialisierung.
    func calculatePrices() async {
        let currencySymbol = product.metaData.first(where: { $0.key == "_currency_symbol" })?.value as? String ?? "€"

        if product.type == .variable, let priceHtml = product.priceHtml, !priceHtml.isEmpty {
            // Wir rufen jetzt die neue, sichere async-Funktion auf.
            self.displayPrice = await PriceFormatter.formatPrice(from: priceHtml) ?? "Preis auf Anfrage"
            self.strikethroughPrice = nil
        } else {
            self.displayPrice = "\(currencySymbol)\(product.price)"
            if product.onSale && !product.regularPrice.isEmpty && product.regularPrice != product.price {
                self.strikethroughPrice = "\(currencySymbol)\(product.regularPrice)"
            } else {
                self.strikethroughPrice = nil
            }
        }
    }
}
