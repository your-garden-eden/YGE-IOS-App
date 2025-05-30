//
//  AppNavigationData.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 30.05.25.
//


// Core/Utils/Config/AppNavigationData.swift
import Foundation

struct AppNavigationData {

    // Hilfsfunktion, um den relevanten Slug aus dem Link zu extrahieren.
    // Beispiel: "/product-list/gartenmoebel-sofas" -> "gartenmoebel-sofas"
    // Beispiel: "/category/gartenmoebel" -> "gartenmoebel"
    static func extractSlug(from link: String, prefixToRemoveIfProductList: String = "/product-list/") -> String {
        if link.hasPrefix(prefixToRemoveIfProductList) {
            return String(link.dropFirst(prefixToRemoveIfProductList.count))
        }
        // Für Kategorieseiten-Links wie "/category/gartenmoebel"
        if link.starts(with: "/category/") {
             return String(link.dropFirst("/category/".count))
        }
        // Fallback, falls der Link bereits der reine Slug ist oder eine andere Struktur hat
        return link.components(separatedBy: "/").last ?? link
    }

    static let items: [AppNavigationItem] = [
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/gartenmoebel"),
            label: "Gartenmöbel",
            i18nId: "header.nav.furniture",
            subItems: [
                AppSubNavigationItem(label: "Sofas", i18nId: "header.nav.furniture.sofas", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sofas"), iconFilename: "Lounges.png"), // Icons anpassen!
                AppSubNavigationItem(label: "Lounges", i18nId: "header.nav.furniture.lounges", linkSlug: extractSlug(from: "/product-list/gartenmoebel-lounges"), iconFilename: "Lounges.png"),
                AppSubNavigationItem(label: "Stühle", i18nId: "header.nav.furniture.chairs", linkSlug: extractSlug(from: "/product-list/gartenmoebel-stuehle"), iconFilename: "GartenSessel.png"),
                AppSubNavigationItem(label: "Gartensessel", i18nId: "header.nav.furniture.armchairs", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sessel"), iconFilename: "GartenSessel.png"),
                AppSubNavigationItem(label: "Sitzgarnituren", i18nId: "header.nav.furniture.seatingGroups", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sitzgarnitur"), iconFilename: "Moebelset.png"),
                AppSubNavigationItem(label: "Möbelgarnituren", i18nId: "header.nav.furniture.furnitureSets", linkSlug: extractSlug(from: "/product-list/gartenmoebel-moebelgarnitur"), iconFilename: "Moebelset.png"),
                AppSubNavigationItem(label: "Gartentische", i18nId: "header.nav.furniture.tables", linkSlug: extractSlug(from: "/product-list/gartenmoebel-tische"), iconFilename: "Tsch.png"), // Prüfe Icon "Tsch.png"
                AppSubNavigationItem(label: "Bänke", i18nId: "header.nav.furniture.benches", linkSlug: extractSlug(from: "/product-list/gartenmoebel-baenke"), iconFilename: "Bank.png"),
                AppSubNavigationItem(label: "Liegen", i18nId: "header.nav.furniture.sunloungers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-liegen"), iconFilename: "Sonnenliege.png"),
                AppSubNavigationItem(label: "Betten", i18nId: "header.nav.furniture.beds", linkSlug: extractSlug(from: "/product-list/gartenmoebel-betten"), iconFilename: "Sonnenliege.png"),
                AppSubNavigationItem(label: "Hängematten", i18nId: "header.nav.furniture.hammocks", linkSlug: extractSlug(from: "/product-list/gartenmoebel-haengematten"), iconFilename: "Hollywood.png"),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.furniture.swings", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schaukeln"), iconFilename: "Hollywood.png")
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/sonnenschutz"),
            label: "Sonnenschutz",
            i18nId: "header.nav.sunprotection",
            subItems: [
                AppSubNavigationItem(label: "Markisen", i18nId: "header.nav.sunprotection.awnings", linkSlug: extractSlug(from: "/product-list/sonnenschutz-markisen"), iconFilename: "Markise.png"),
                AppSubNavigationItem(label: "Sonnenschirme", i18nId: "header.nav.sunprotection.umbrellas", linkSlug: extractSlug(from: "/product-list/sonnenschutz-sonnenschirme"), iconFilename: "Sonnenschirm.png"),
                AppSubNavigationItem(label: "Sonnensegel", i18nId: "header.nav.sunprotection.sunsails", linkSlug: extractSlug(from: "/product-list/sonnenschutz-sonnensegel"), iconFilename: "Sonnenschirm.png"), // Ggf. anderes Icon
                AppSubNavigationItem(label: "Zubehör Sonnenschutz", i18nId: "header.nav.sunprotection.accessories", linkSlug: extractSlug(from: "/product-list/sonnenschutz-zubehoer"), iconFilename: "Logo.png")
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/wasser-im-garten"),
            label: "Wasser im Garten",
            i18nId: "header.nav.water",
            subItems: [
                AppSubNavigationItem(label: "Pools", i18nId: "header.nav.water.pools", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-pools"), iconFilename: "Pool.png"),
                AppSubNavigationItem(label: "Teiche", i18nId: "header.nav.water.ponds", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-teiche"), iconFilename: "Teich.png"),
                AppSubNavigationItem(label: "Zubehör Wasser", i18nId: "header.nav.water.accessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-zubehoer"), iconFilename: "Logo.png")
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/heizen-feuer"),
            label: "Heizen & Feuer",
            i18nId: "header.nav.heating",
            subItems: [
                AppSubNavigationItem(label: "Kamine", i18nId: "header.nav.heating.fireplaces", linkSlug: extractSlug(from: "/product-list/heizen-feuer-kamine"), iconFilename: "Feuer.png"),
                AppSubNavigationItem(label: "Feuerschalen", i18nId: "header.nav.heating.firebowls", linkSlug: extractSlug(from: "/product-list/heizen-feuer-feuerschale"), iconFilename: "Feuer.png"),
                AppSubNavigationItem(label: "Heizstrahler", i18nId: "header.nav.heating.heaters", linkSlug: extractSlug(from: "/product-list/heizen-feuer-heizstrahler"), iconFilename: "Logo.png"),
                AppSubNavigationItem(label: "Feuerholzaufbewahrung", i18nId: "header.nav.heating.firewoodstorage", linkSlug: extractSlug(from: "/product-list/heizen-feuer-feuerholzaufbewahrung"), iconFilename: "Holz.png")
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/gartenhelfer-aufbewahrung"),
            label: "Gartenhelfer & Aufbewahrung",
            i18nId: "header.nav.gardenhelpers",
            subItems: [
                AppSubNavigationItem(label: "Gartengeräte", i18nId: "header.nav.gardenhelpers.tools", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartengeraete"), iconFilename: "Maeher.png"),
                AppSubNavigationItem(label: "Gartenschuppen", i18nId: "header.nav.gardenhelpers.sheds", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartenschuppen"), iconFilename: "Logo.png"), // Slug in Daten: "gartenschuppen"
                AppSubNavigationItem(label: "Aufbewahrung", i18nId: "header.nav.gardenhelpers.storagegeneral", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung"), iconFilename: "Box.png"), // Dieser Link ist "/product-list/gartenhelfer-aufbewahrung" -> Slug: "gartenhelfer-aufbewahrung"
                AppSubNavigationItem(label: "Komposter", i18nId: "header.nav.gardenhelpers.composters", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-komposter"), iconFilename: "BIO.png"),
                AppSubNavigationItem(label: "Regentonnen", i18nId: "header.nav.gardenhelpers.waterbutts", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-regentonnen"), iconFilename: "BIO.png"),
                AppSubNavigationItem(label: "Werkzeug", i18nId: "header.nav.gardenhelpers.toolstorage", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-werkzeug"), iconFilename: "Logo.png") // Slug in Daten: "werkzeug"
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/deko-licht"),
            label: "Dekoration & Licht",
            i18nId: "header.nav.deco",
            subItems: [
                AppSubNavigationItem(label: "Gartenbeleuchtung", i18nId: "header.nav.deco.lighting", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenbeleuchtung"), iconFilename: "Lampe.png"),
                AppSubNavigationItem(label: "Gartendeko", i18nId: "header.nav.deco.decoration", linkSlug: extractSlug(from: "/product-list/deko-licht-gartendeko"), iconFilename: "Deko.png"),
                AppSubNavigationItem(label: "Gartenteppiche", i18nId: "header.nav.deco.rugs", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenteppiche"), iconFilename: "Teppich.png"),
                AppSubNavigationItem(label: "Weihnachtsdeko", i18nId: "header.nav.deco.christmas", linkSlug: extractSlug(from: "/product-list/deko-licht-weihnachtsdeko"), iconFilename: "Logo.png")
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/pflanzen-anzucht"),
            label: "Pflanzen & Anzucht",
            i18nId: "header.nav.plants",
            subItems: [
                AppSubNavigationItem(label: "Gewächshäuser", i18nId: "header.nav.plants.greenhouses", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-gewaechshaeuser"), iconFilename: "Gewaechs.png"),
                AppSubNavigationItem(label: "Hochbeete", i18nId: "header.nav.plants.raisedbeds", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-hochbeet"), iconFilename: "Topf.png"), // Slug "hochbeet"
                AppSubNavigationItem(label: "Kunstpflanzen", i18nId: "header.nav.plants.artificial", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-kunstpflanzen"), iconFilename: "kunst.png"),
                AppSubNavigationItem(label: "Pflanzenschutz", i18nId: "header.nav.plants.protection", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzenschutz"), iconFilename: "Schutz.png"),
                AppSubNavigationItem(label: "Pflanzgefäße", i18nId: "header.nav.plants.planters", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzgefaesse"), iconFilename: "Topf.png"),
                AppSubNavigationItem(label: "Rankhilfen", i18nId: "header.nav.plants.trellises", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-rankhilfen"), iconFilename: "ranken.png")
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/fuer-die-ganze-grossen"), // Slug der Hauptkategorie
            label: "Spiel & Spaß",
            i18nId: "header.nav.playfun",
            subItems: [
                AppSubNavigationItem(label: "Sandkästen", i18nId: "header.nav.playfun.sandpits", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-sandkasten"), iconFilename: "sandkasten.png"), // Slug "sandkasten"
                AppSubNavigationItem(label: "Spielburgen", i18nId: "header.nav.playfun.playcastles", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-spielburgen"), iconFilename: "Logo.png"),
                AppSubNavigationItem(label: "Trampoline", i18nId: "header.nav.playfun.trampolines", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-trampoline"), iconFilename: "Logo.png"),
                AppSubNavigationItem(label: "Zubehör Spiel & Spaß", i18nId: "header.nav.playfun.accessories", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-zubehoer"), iconFilename: "Logo.png")
            ]
        )
    ]

    // Hilfsfunktion, um ein AppNavigationItem anhand des Hauptkategorie-Slugs zu finden
    // Wird verwendet, um von der Auswahl in CategoryListView (die ein WooCommerceCategory-Objekt ist)
    // zum entsprechenden AppNavigationItem für die SubCategoryListView zu gelangen.
    static func findItem(forMainCategorySlug slug: String) -> AppNavigationItem? {
        return items.first { $0.mainCategorySlug.lowercased() == slug.lowercased() }
    }
}