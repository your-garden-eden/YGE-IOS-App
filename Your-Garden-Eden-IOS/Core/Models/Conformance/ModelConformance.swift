// DATEI: ModelConformance.swift
// PFAD: Models/Extensions/ModelConformance.swift
// VERSION: KORRIGIERT & FINAL
// ÄNDERUNG: Die fehlerhafte `ProductDisplayable`-Konformität für das `Item`-Modell
//           wurde entfernt, um den Kompilierungsfehler zu beheben.

import Foundation
import SwiftUI

// MARK: - WooCommerceProduct Conformance
// Diese Konformität ist korrekt und bleibt bestehen.
extension WooCommerceProduct: ProductDisplayable {
    
    public var displayId: Int {
        return self.id
    }
    
    public var displayName: String {
        return self.name.strippingHTML()
    }
    
    public var displayImageURL: URL? {
        return self.safeImages.first?.src.asURL()
    }
    
    public var displayPrice: String {
        return PriceFormatter.formatDisplayPrice(for: self).display
    }
    
    public var displayStrikethroughPrice: String? {
        return PriceFormatter.formatDisplayPrice(for: self).strikethrough
    }
    
    public var displayStockStatus: (text: String, color: Color) {
        switch self.stock_status {
        case .instock:
            return ("Auf Lager", AppTheme.Colors.success)
        case .outofstock:
            return ("Nicht verfügbar", AppTheme.Colors.error)
        case .onbackorder:
            return ("Nachbestellbar", AppTheme.Colors.textMuted)
        }
    }
    
    public func asWooCommerceProduct() -> WooCommerceProduct? {
        // Da es bereits ein WooCommerceProduct ist, gibt es sich selbst zurück.
        return self
    }
}

// Die fehlerhafte Erweiterung für 'Item' wurde hier vollständig entfernt.
