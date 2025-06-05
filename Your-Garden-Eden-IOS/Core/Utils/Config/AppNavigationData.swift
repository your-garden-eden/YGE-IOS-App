// Core/Utils/Config/AppNavigationData.swift
import Foundation

struct AppNavigationData {

    static func extractSlug(from link: String, prefixToRemoveIfProductList: String = "/product-list/") -> String {
        if link.hasPrefix(prefixToRemoveIfProductList) {
            return String(link.dropFirst(prefixToRemoveIfProductList.count))
        }
        if link.starts(with: "/category/") {
             return String(link.dropFirst("/category/".count))
        }
        return link.components(separatedBy: "/").last ?? link
    }

    static let items: [AppNavigationItem] = [
        // --- Gartenmöbel ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/gartenmoebel"), // "gartenmoebel"
            label: "Gartenmöbel",
            i18nId: "header.nav.furniture",
            subItems: [
                AppSubNavigationItem(label: "Sofas", i18nId: "header.nav.furniture.sofas", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sofas"), iconFilename: "Gatensofas.png"),
                AppSubNavigationItem(label: "Stühle", i18nId: "header.nav.furniture.chairs", linkSlug: extractSlug(from: "/product-list/gartenmoebel-stuehle"), iconFilename: "GartenSessel.png"),
                AppSubNavigationItem(label: "Hocker", i18nId: "header.nav.furniture.stools", linkSlug: extractSlug(from: "/product-list/gartenmoebel-hocker"), iconFilename: "hocker.png"),
                AppSubNavigationItem(label: "Sitzpolster", i18nId: "header.nav.furniture.seatingGroups", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sitzpolster"), iconFilename: "polster.png"), // i18nId .seatingGroups
                AppSubNavigationItem(label: "Gartentische", i18nId: "header.nav.furniture.tables", linkSlug: extractSlug(from: "/product-list/gartenmoebel-tische"), iconFilename: "Tsch.png"),
                AppSubNavigationItem(label: "Bänke", i18nId: "header.nav.furniture.benches", linkSlug: extractSlug(from: "/product-list/gartenmoebel-baenke"), iconFilename: "Bank.png"),
                AppSubNavigationItem(label: "Liegen", i18nId: "header.nav.furniture.sunloungers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-liegen"), iconFilename: "Sonnenliege.png"),
                AppSubNavigationItem(label: "Betten", i18nId: "header.nav.furniture.beds", linkSlug: extractSlug(from: "/product-list/gartenmoebel-betten"), iconFilename: "Bett.png"),
                AppSubNavigationItem(label: "Hängematten", i18nId: "header.nav.furniture.hammocks", linkSlug: extractSlug(from: "/product-list/gartenmoebel-haengematten"), iconFilename: "haengmatte.png"),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.furniture.swings", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schaukeln"), iconFilename: "Hollywood.png"),
                AppSubNavigationItem(label: "Schutzhüllen", i18nId: "header.nav.furniture.covers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schutzhuellen"), iconFilename: "Schutzhuelle.png"),
                AppSubNavigationItem(label: "Boxen", i18nId: "header.nav.furniture.box", linkSlug: extractSlug(from: "/product-list/gartenmoebel-boxen"), iconFilename: "gartenbox.png")
            ]
        ),

        // --- Sonnenschutz ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/sonnenschutz"), // "sonnenschutz"
            label: "Sonnenschutz",
            i18nId: "header.nav.sunprotection",
            subItems: [
                AppSubNavigationItem(label: "Markisen", i18nId: "header.nav.sunprotection.awnings", linkSlug: extractSlug(from: "/product-list/sonnenschutz-markisen"), iconFilename: "Markise.png"),
                AppSubNavigationItem(label: "Sonnenschirme", i18nId: "header.nav.sunprotection.umbrellas", linkSlug: extractSlug(from: "/product-list/sonnenschutz-sonnenschirme"), iconFilename: "Sonnenschirm.png"),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.sunprotection.accessories", linkSlug: extractSlug(from: "/product-list/sonnenschutz-zubehoer"), iconFilename: "schrimzubehoer.png")
            ]
        ),

        // --- Wasser im Garten ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/wasser-im-garten"), // "wasser-im-garten"
            label: "Wasser im Garten",
            i18nId: "header.nav.water",
            subItems: [
                AppSubNavigationItem(label: "Pools", i18nId: "header.nav.water.pools", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-pools"), iconFilename: "Pool.png"),
                AppSubNavigationItem(label: "Teichzubehör", i18nId: "header.nav.water.pondAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-teichzubehoer"), iconFilename: "teichzubehoer.png"),
                AppSubNavigationItem(label: "Poolzubehör", i18nId: "header.nav.water.poolAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-poolzubehoer"), iconFilename: "pollzubehoer.png")
            ]
        ),

        // --- Heizen & Feuer ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/heizen-feuer"), // "heizen-feuer"
            label: "Heizen & Feuer",
            i18nId: "header.nav.heating",
            subItems: [
                AppSubNavigationItem(label: "Kamine", i18nId: "header.nav.heating.fireplaces", linkSlug: extractSlug(from: "/product-list/heizen-feuer-kamine"), iconFilename: "Feuer.png"),
                AppSubNavigationItem(label: "Feuerholzaufbewahrung", i18nId: "header.nav.heating.firewoodstorage", linkSlug: extractSlug(from: "/product-list/heizen-feuer-feuerholzaufbewahrung"), iconFilename: "Holz.png"),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.heating.heaters", linkSlug: extractSlug(from: "/product-list/heizen-feuer-zubehoer"), iconFilename: "holzzubehoer.png") // i18nId .heaters
            ]
        ),

        // --- Gartenhelfer & Aufbewahrung ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/gartenhelfer-aufbewahrung"), // "gartenhelfer-aufbewahrung"
            label: "Gartenhelfer & Aufbewahrung",
            i18nId: "header.nav.gardenhelpers",
            subItems: [
                AppSubNavigationItem(label: "Gartengeräte", i18nId: "header.nav.gardenhelpers.tools", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartengeraete"), iconFilename: "Maeher.png"),
                AppSubNavigationItem(label: "Gartenschuppen", i18nId: "header.nav.gardenhelpers.sheds", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartenschuppen"), iconFilename: "schuppen.png"),
                AppSubNavigationItem(label: "Komposter", i18nId: "header.nav.gardenhelpers.composters", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-komposter"), iconFilename: "BIO.png"),
                AppSubNavigationItem(label: "Regentonnen", i18nId: "header.nav.gardenhelpers.waterbutts", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-regentonnen"), iconFilename: "regentonne.png"),
                AppSubNavigationItem(label: "Gartenwerkzeug", i18nId: "header.nav.gardenhelpers.toolstorage", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-werkzeug"), iconFilename: "werkzeug.png")
            ]
        ),

        // --- Dekoration & Licht ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/deko-licht"), // "deko-licht"
            label: "Dekoration & Licht",
            i18nId: "header.nav.deco",
            subItems: [
                AppSubNavigationItem(label: "Gartenbeleuchtung", i18nId: "header.nav.deco.lighting", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenbeleuchtung"), iconFilename: "Lampe.png"),
                AppSubNavigationItem(label: "Gartenlautsprecher", i18nId: "header.nav.deco.audio", linkSlug: extractSlug(from: "/product-list/deko-licht-audio"), iconFilename: "audio.png"),
                AppSubNavigationItem(label: "Gartendeko", i18nId: "header.nav.deco.decoration", linkSlug: extractSlug(from: "/product-list/deko-licht-gartendeko"), iconFilename: "Deko.png"),
                AppSubNavigationItem(label: "Gartenteppiche", i18nId: "header.nav.deco.rugs", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenteppiche"), iconFilename: "Teppich.png"),
                AppSubNavigationItem(label: "Weihnachtsdeko", i18nId: "header.nav.deco.christmas", linkSlug: extractSlug(from: "/product-list/deko-licht-weihnachtsdeko"), iconFilename: "weihnacht.png")
            ]
        ),

        // --- Pflanzen & Anzucht ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/pflanzen-anzucht"), // "pflanzen-anzucht"
            label: "Pflanzen & Anzucht",
            i18nId: "header.nav.plants",
            subItems: [
                AppSubNavigationItem(label: "Gewächshäuser", i18nId: "header.nav.plants.greenhouses", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-gewaechshaeuser"), iconFilename: "Gewaechs.png"),
                AppSubNavigationItem(label: "Hochbeete", i18nId: "header.nav.plants.raisedbeds", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-hochbeet"), iconFilename: "gatenbox.png"), // Gemäß deiner Daten: gatenbox.png
                AppSubNavigationItem(label: "Tische", i18nId: "header.nav.plants.tables", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-tische"), iconFilename: "planztisch.png"),
                AppSubNavigationItem(label: "Ständer", i18nId: "header.nav.plants.stands", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-staender"), iconFilename: "staender.png"),
                AppSubNavigationItem(label: "Kunstpflanzen", i18nId: "header.nav.plants.artificial", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-kunstpflanzen"), iconFilename: "kunst.png"),
                AppSubNavigationItem(label: "Pflanzenschutz", i18nId: "header.nav.plants.protection", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzenschutz"), iconFilename: "Schutz.png"),
                AppSubNavigationItem(label: "Pflanzgefäße", i18nId: "header.nav.plants.planters", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzgefaesse"), iconFilename: "Topf.png"),
                AppSubNavigationItem(label: "Rankhilfen", i18nId: "header.nav.plants.trellises", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-rankhilfen"), iconFilename: "ranken.png"),
                AppSubNavigationItem(label: "Bewässerung", i18nId: "header.nav.plants.irrigation", linkSlug: extractSlug(from: "/product-list/pflanzen-ansucht-bewaesserung"), iconFilename: "bewaesserung.png") // Link "ansucht" beibehalten
            ]
        ),

        // --- Spiel & Spaß ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/fuer-die-ganze-grossen"), // "fuer-die-ganze-grossen"
            label: "Spiel & Spaß",
            i18nId: "header.nav.playfun",
            subItems: [
                AppSubNavigationItem(label: "Sandkästen", i18nId: "header.nav.playfun.sandpits", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-sandkasten"), iconFilename: "sandkasten.png"),
                AppSubNavigationItem(label: "Spielburgen", i18nId: "header.nav.playfun.playcastles", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-spielburgen"), iconFilename: "spielburgen.png"),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.playfun.swings", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-schaukeln"), iconFilename: "schukel.png"),
                AppSubNavigationItem(label: "Trampoline", i18nId: "header.nav.playfun.trampolines", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-trampoline"), iconFilename: "trampo.png"),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.playfun.accessories", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-zubehoer"), iconFilename: "trampozubehoer.png")
            ]
        )
    ]

    static func findItem(forMainCategorySlug slug: String) -> AppNavigationItem? {
        return items.first { $0.mainCategorySlug.lowercased() == slug.lowercased() }
    }
}
