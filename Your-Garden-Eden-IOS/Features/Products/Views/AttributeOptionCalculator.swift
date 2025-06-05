//
//  AttributeOptionCalculator.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 06.06.25.
//


import Foundation

struct AttributeOptionCalculator {
    
    // Schritt 1: Definiere einen einfachen, privaten Helfer-Struct.
    // Dies gibt dem Compiler eine klare "Blaupause" für die Daten.
    private struct CalculatedOption {
        let displayName: String
        let slug: String
    }
    
    // Diese Funktion übernimmt die gesamte komplexe Logik.
    // Sie ist 'static', damit wir keine Instanz der Klasse erstellen müssen.
    static func calculate(
        for attribute: WooCommerceAttribute,
        from allVariations: [WooCommerceProductVariation]
    ) -> [(displayName: String, slug: String)] {
        
        var uniqueOptions = [String: String]() // Key: Slug, Value: DisplayName

        for variation in allVariations {
            // Finde das passende Attribut in der aktuellen Variation
            // Dieser Teil bleibt gleich, da er bereits korrigiert wurde.
            if let variationAttribute = variation.attributes.first(where: { varAttr -> Bool in
                if attribute.id != 0 && varAttr.id != 0 && varAttr.id == attribute.id { return true }
                if varAttr.name == attribute.name { return true }
                if let varAttrSlug = varAttr.slug, varAttrSlug == attribute.slugOrNameAsSlug() { return true }
                return false
            }) {
                let optionDisplayName = variationAttribute.option
                let optionSlug = variationAttribute.optionAsSlug()
                
                if uniqueOptions[optionSlug] == nil {
                    uniqueOptions[optionSlug] = optionDisplayName
                }
            }
        }
        
        // KORREKTUR: Wir verwenden den Helfer-Struct für die Transformation.
        
        // Schritt 2: Wandle das Dictionary in ein Array von `CalculatedOption`-Objekten um.
        // Der Aufruf des Struct-Initializers `CalculatedOption(...)` ist für den Compiler sehr einfach.
        let mappedOptions: [CalculatedOption] = uniqueOptions.map { (slug, displayName) in
            return CalculatedOption(displayName: displayName, slug: slug)
        }
        
        // Schritt 3: Sortiere das Array der Struct-Objekte. Das ist ebenfalls sehr einfach für den Compiler.
        let sortedOptions = mappedOptions.sorted { $0.displayName < $1.displayName }
        
        // Schritt 4: Wandle das sortierte Array von Structs zurück in das benötigte Array von Tupeln.
        // Dieser letzte, einfache Mapping-Schritt ist unproblematisch.
        let finalResult = sortedOptions.map { (displayName: $0.displayName, slug: $0.slug) }
        
        return finalResult
    }
}
