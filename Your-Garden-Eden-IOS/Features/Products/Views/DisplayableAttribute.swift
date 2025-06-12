//
//  DisplayableAttribute.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 12.06.25.
//


// In ProductDetailViewModel.swift oder einer separaten Model-Datei einfügen

struct DisplayableAttribute: Identifiable, Hashable {
    let id: String // `id` macht es Identifiable. Wir benutzen den slug.
    let name: String
    let slug: String
    let options: [DisplayableOption]
    
    // Wir nutzen den slug als eindeutige ID für die ForEach-Schleife
    init(name: String, slug: String, options: [DisplayableOption]) {
        self.id = slug
        self.name = name
        self.slug = slug
        self.options = options
    }
}

struct DisplayableOption: Identifiable, Hashable {
    let id: String // `id` macht es Identifiable. Wir benutzen den slug.
    let name: String
    let slug: String
    
    // Wir nutzen den slug als eindeutige ID für die ForEach-Schleife
    init(name: String, slug: String) {
        self.id = slug
        self.name = name
        self.slug = slug
    }
}