// DATEI: NavigationData.swift
// PFAD: Helper/NavigationData.swift
// VERSION: 2.0 (FINAL & BEREINIGT)
// ZWECK: Enthält die statische, hierarchische Struktur der Hauptnavigation der App.
//        Diese Akte ist entkoppelt von visuellen Darstellungsdetails.

import Foundation

/// Repräsentiert eine Hauptkategorie in der Navigation.
public struct AppNavigationItem: Identifiable, Hashable {
    public let id = UUID()
    public let mainCategorySlug: String
    public let label: String
    public let i18nId: String
    // KORREKTUR: `imageFilename` wurde entfernt. Die Verantwortung liegt nun beim ImageProvider.
    public let subItems: [AppSubNavigationItem]?
}

/// Repräsentiert einen Unterpunkt (eine Sub-Kategorie) innerhalb einer Hauptkategorie.
public struct AppSubNavigationItem: Identifiable, Hashable {
    public let id = UUID()
    public let label: String
    public let i18nId: String
    public let linkSlug: String
}

/// Stellt die statischen Navigationsdaten für die gesamte Anwendung bereit.
public struct NavigationData {
    private static func extractSlug(from link: String, prefixToRemove: String) -> String {
        if link.hasPrefix(prefixToRemove) {
            return link.replacingOccurrences(of: prefixToRemove, with: "")
        }
        return link
    }
    
    public static let items: [AppNavigationItem] = [
        AppNavigationItem(
            mainCategorySlug: "gartenmoebel", label: "Gartenmöbel", i18nId: "header.nav.furniture",
            subItems: [
                AppSubNavigationItem(label: "Sofas", i18nId: "header.nav.furniture.sofas", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sofas", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Stühle", i18nId: "header.nav.furniture.chairs", linkSlug: extractSlug(from: "/product-list/gartenmoebel-stuehle", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Hocker", i18nId: "header.nav.furniture.stools", linkSlug: extractSlug(from: "/product-list/gartenmoebel-hocker", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Sitzpolster", i18nId: "header.nav.furniture.seatingGroups", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sitzpolster", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartentische", i18nId: "header.nav.furniture.tables", linkSlug: extractSlug(from: "/product-list/gartenmoebel-tische", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Bänke", i18nId: "header.nav.furniture.benches", linkSlug: extractSlug(from: "/product-list/gartenmoebel-baenke", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Liegen", i18nId: "header.nav.furniture.sunloungers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-liegen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Betten", i18nId: "header.nav.furniture.beds", linkSlug: extractSlug(from: "/product-list/gartenmoebel-betten", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Hängematten", i18nId: "header.nav.furniture.hammocks", linkSlug: extractSlug(from: "/product-list/gartenmoebel-haengematten", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.furniture.swings", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schaukeln", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Schutzhüllen", i18nId: "header.nav.furniture.covers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schutzhuellen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Boxen", i18nId: "header.nav.furniture.box", linkSlug: extractSlug(from: "/product-list/gartenmoebel-boxen", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "sonnenschutz", label: "Sonnenschutz", i18nId: "header.nav.sunprotection",
            subItems: [
                AppSubNavigationItem(label: "Markisen", i18nId: "header.nav.sunprotection.awnings", linkSlug: extractSlug(from: "/product-list/sonnenschutz-markisen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Sonnenschirme", i18nId: "header.nav.sunprotection.umbrellas", linkSlug: extractSlug(from: "/product-list/sonnenschutz-sonnenschirme", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.sunprotection.accessories", linkSlug: extractSlug(from: "/product-list/sonnenschutz-zubehoer", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "wasser-im-garten", label: "Wasser im Garten", i18nId: "header.nav.water",
            subItems: [
                AppSubNavigationItem(label: "Pools", i18nId: "header.nav.water.pools", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-pools", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Teichzubehör", i18nId: "header.nav.water.pondAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-teichzubehoer", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Poolzubehör", i18nId: "header.nav.water.poolAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-poolzubehoer", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "heizen-feuer", label: "Heizen & Feuer", i18nId: "header.nav.heating",
            subItems: [
                AppSubNavigationItem(label: "Kamine", i18nId: "header.nav.heating.fireplaces", linkSlug: extractSlug(from: "/product-list/heizen-feuer-kamine", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Feuerholzaufbewahrung", i18nId: "header.nav.heating.firewoodstorage", linkSlug: extractSlug(from: "/product-list/heizen-feuer-feuerholzaufbewahrung", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.heating.heaters", linkSlug: extractSlug(from: "/product-list/heizen-feuer-zubehoer", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "gartenhelfer-aufbewahrung", label: "Gartenhelfer & Aufbewahrung", i18nId: "header.nav.gardenhelpers",
            subItems: [
                AppSubNavigationItem(label: "Gartengeräte", i18nId: "header.nav.gardenhelpers.tools", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartengeraete", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartenschuppen", i18nId: "header.nav.gardenhelpers.sheds", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartenschuppen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Komposter", i18nId: "header.nav.gardenhelpers.composters", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-komposter", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Regentonnen", i18nId: "header.nav.gardenhelpers.waterbutts", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-regentonnen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartenwerkzeug", i18nId: "header.nav.gardenhelpers.toolstorage", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-werkzeug", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "deko-licht", label: "Dekoration & Licht", i18nId: "header.nav.deco",
            subItems: [
                AppSubNavigationItem(label: "Gartenbeleuchtung", i18nId: "header.nav.deco.lighting", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenbeleuchtung", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartenlautsprecher", i18nId: "header.nav.deco.audio", linkSlug: extractSlug(from: "/product-list/deko-licht-audio", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartendeko", i18nId: "header.nav.deco.decoration", linkSlug: extractSlug(from: "/product-list/deko-licht-gartendeko", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartenteppiche", i18nId: "header.nav.deco.rugs", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenteppiche", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Weihnachtsdeko", i18nId: "header.nav.deco.christmas", linkSlug: extractSlug(from: "/product-list/deko-licht-weihnachtsdeko", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "pflanzen-anzucht", label: "Pflanzen & Anzucht", i18nId: "header.nav.plants",
            subItems: [
                AppSubNavigationItem(label: "Gewächshäuser", i18nId: "header.nav.plants.greenhouses", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-gewaechshaeuser", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Hochbeete", i18nId: "header.nav.plants.raisedbeds", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-hochbeet", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Tische", i18nId: "header.nav.plants.tables", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-tische", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Ständer", i18nId: "header.nav.plants.stands", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-staender", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Kunstpflanzen", i18nId: "header.nav.plants.artificial", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-kunstpflanzen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Pflanzenschutz", i18nId: "header.nav.plants.protection", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzenschutz", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Pflanzgefäße", i18nId: "header.nav.plants.planters", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzgefaesse", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Rankhilfen", i18nId: "header.nav.plants.trellises", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-rankhilfen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Bewässerung", i18nId: "header.nav.plants.irrigation", linkSlug: extractSlug(from: "/product-list/pflanzen-ansucht-bewaesserung", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "fuer-die-ganze-grossen", label: "Spiel & Spaß", i18nId: "header.nav.playfun",
            subItems: [
                AppSubNavigationItem(label: "Sandkästen", i18nId: "header.nav.playfun.sandpits", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-sandkasten", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Spielburgen", i18nId: "header.nav.playfun.playcastles", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-spielburgen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.playfun.swings", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-schaukeln", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Trampoline", i18nId: "header.nav.playfun.trampolines", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-trampoline", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.playfun.accessories", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-zubehoer", prefixToRemove: "/product-list/"))
            ]
        )
    ]
}
