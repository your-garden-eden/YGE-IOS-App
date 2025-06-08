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
            mainCategorySlug: extractSlug(from: "/category/gartenmoebel"),
            label: "Gartenmöbel",
            i18nId: "header.nav.furniture",
            imageFilename: "cat_banner_gartenmoebel.jpg",
            subItems: [
                AppSubNavigationItem(label: "Sofas", i18nId: "header.nav.furniture.sofas", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sofas"), iconFilename: "Gatensofas"),
                AppSubNavigationItem(label: "Stühle", i18nId: "header.nav.furniture.chairs", linkSlug: extractSlug(from: "/product-list/gartenmoebel-stuehle"), iconFilename: "GartenSessel"),
                AppSubNavigationItem(label: "Hocker", i18nId: "header.nav.furniture.stools", linkSlug: extractSlug(from: "/product-list/gartenmoebel-hocker"), iconFilename: "hocker"),
                AppSubNavigationItem(label: "Sitzpolster", i18nId: "header.nav.furniture.seatingGroups", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sitzpolster"), iconFilename: "polster"),
                AppSubNavigationItem(label: "Gartentische", i18nId: "header.nav.furniture.tables", linkSlug: extractSlug(from: "/product-list/gartenmoebel-tische"), iconFilename: "Tsch"),
                AppSubNavigationItem(label: "Bänke", i18nId: "header.nav.furniture.benches", linkSlug: extractSlug(from: "/product-list/gartenmoebel-baenke"), iconFilename: "Bank"),
                AppSubNavigationItem(label: "Liegen", i18nId: "header.nav.furniture.sunloungers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-liegen"), iconFilename: "Sonnenliege"),
                AppSubNavigationItem(label: "Betten", i18nId: "header.nav.furniture.beds", linkSlug: extractSlug(from: "/product-list/gartenmoebel-betten"), iconFilename: "Bett"),
                AppSubNavigationItem(label: "Hängematten", i18nId: "header.nav.furniture.hammocks", linkSlug: extractSlug(from: "/product-list/gartenmoebel-haengematten"), iconFilename: "haengmatte"),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.furniture.swings", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schaukeln"), iconFilename: "Hollywood"),
                AppSubNavigationItem(label: "Schutzhüllen", i18nId: "header.nav.furniture.covers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schutzhuellen"), iconFilename: "Schutzhuelle"),
                AppSubNavigationItem(label: "Boxen", i18nId: "header.nav.furniture.box", linkSlug: extractSlug(from: "/product-list/gartenmoebel-boxen"), iconFilename: "gartenbox")
            ]
        ),

        // --- Sonnenschutz ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/Sonnenschutz"),
            label: "Sonnenschutz",
            i18nId: "header.nav.sunprotection",
            imageFilename: "cat_banner_sonnenschutz.jpg",
            subItems: [
                AppSubNavigationItem(label: "Markisen", i18nId: "header.nav.sunprotection.awnings", linkSlug: extractSlug(from: "/product-list/sonnenschutz-markisen"), iconFilename: "Markise"),
                AppSubNavigationItem(label: "Sonnenschirme", i18nId: "header.nav.sunprotection.umbrellas", linkSlug: extractSlug(from: "/product-list/sonnenschutz-sonnenschirme"), iconFilename: "Sonnenschirm"),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.sunprotection.accessories", linkSlug: extractSlug(from: "/product-list/sonnenschutz-zubehoer"), iconFilename: "schrimzubehoer")
            ]
        ),

        // --- Wasser im Garten ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/wasser-im-garten"),
            label: "Wasser im Garten",
            i18nId: "header.nav.water",
            imageFilename: "cat_banner_wasser-im-garten.jpg",
            subItems: [
                AppSubNavigationItem(label: "Pools", i18nId: "header.nav.water.pools", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-pools"), iconFilename: "Pool"),
                AppSubNavigationItem(label: "Teichzubehör", i18nId: "header.nav.water.pondAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-teichzubehoer"), iconFilename: "teichzubehoer"),
                AppSubNavigationItem(label: "Poolzubehör", i18nId: "header.nav.water.poolAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-poolzubehoer"), iconFilename: "pollzubehoer")
            ]
        ),

        // --- Heizen-Feuer ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/heizen-feuer"),
            label: "Heizen-Feuer", // GEÄNDERT
            i18nId: "header.nav.heating",
            imageFilename: "cat_banner_heizen-feuer.jpg",
            subItems: [
                AppSubNavigationItem(label: "Kamine", i18nId: "header.nav.heating.fireplaces", linkSlug: extractSlug(from: "/product-list/heizen-feuer-kamine"), iconFilename: "Feuer"),
                AppSubNavigationItem(label: "Feuerholzaufbewahrung", i18nId: "header.nav.heating.firewoodstorage", linkSlug: extractSlug(from: "/product-list/heizen-feuer-feuerholzaufbewahrung"), iconFilename: "Holz"),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.heating.heaters", linkSlug: extractSlug(from: "/product-list/heizen-feuer-zubehoer"), iconFilename: "holzzubehoer")
            ]
        ),

        // --- Gartenhelfer-Aufbewahrung ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/gartenhelfer-aufbewahrung"),
            label: "Gartenhelfer-Aufbewahrung", // GEÄNDERT
            i18nId: "header.nav.gardenhelpers",
            imageFilename: "cat_banner_gartenhelfer.jpg",
            subItems: [
                AppSubNavigationItem(label: "Gartengeräte", i18nId: "header.nav.gardenhelpers.tools", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartengeraete"), iconFilename: "Maeher"),
                AppSubNavigationItem(label: "Gartenschuppen", i18nId: "header.nav.gardenhelpers.sheds", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartenschuppen"), iconFilename: "schuppen"),
                AppSubNavigationItem(label: "Komposter", i18nId: "header.nav.gardenhelpers.composters", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-komposter"), iconFilename: "BIO"),
                AppSubNavigationItem(label: "Regentonnen", i18nId: "header.nav.gardenhelpers.waterbutts", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-regentonnen"), iconFilename: "regentonne"),
                AppSubNavigationItem(label: "Gartenwerkzeug", i18nId: "header.nav.gardenhelpers.toolstorage", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-werkzeug"), iconFilename: "werkzeug")
            ]
        ),

        // --- Deko-Licht ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/deko-licht"),
            label: "Deko-Licht", // GEÄNDERT
            i18nId: "header.nav.deco",
            imageFilename: "cat_banner_deko-licht.jpg",
            subItems: [
                AppSubNavigationItem(label: "Gartenbeleuchtung", i18nId: "header.nav.deco.lighting", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenbeleuchtung"), iconFilename: "Lampe"),
                AppSubNavigationItem(label: "Gartenlautsprecher", i18nId: "header.nav.deco.audio", linkSlug: extractSlug(from: "/product-list/deko-licht-audio"), iconFilename: "audio"),
                AppSubNavigationItem(label: "Gartendeko", i18nId: "header.nav.deco.decoration", linkSlug: extractSlug(from: "/product-list/deko-licht-gartendeko"), iconFilename: "Deko"),
                AppSubNavigationItem(label: "Gartenteppiche", i18nId: "header.nav.deco.rugs", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenteppiche"), iconFilename: "Teppich"),
                AppSubNavigationItem(label: "Weihnachtsdeko", i18nId: "header.nav.deco.christmas", linkSlug: extractSlug(from: "/product-list/deko-licht-weihnachtsdeko"), iconFilename: "weihnacht")
            ]
        ),

        // --- Pflanzen-Anzucht ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/pflanzen-anzucht"),
            label: "Pflanzen-Anzucht", // GEÄNDERT
            i18nId: "header.nav.plants",
            imageFilename: "cat_banner_pflanzen-anzucht.jpg",
            subItems: [
                AppSubNavigationItem(label: "Gewächshäuser", i18nId: "header.nav.plants.greenhouses", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-gewaechshaeuser"), iconFilename: "Gewaechs"),
                AppSubNavigationItem(label: "Hochbeete", i18nId: "header.nav.plants.raisedbeds", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-hochbeet"), iconFilename: "gatenbox"),
                AppSubNavigationItem(label: "Tische", i18nId: "header.nav.plants.tables", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-tische"), iconFilename: "planztisch"),
                AppSubNavigationItem(label: "Ständer", i18nId: "header.nav.plants.stands", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-staender"), iconFilename: "staender"),
                AppSubNavigationItem(label: "Kunstpflanzen", i18nId: "header.nav.plants.artificial", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-kunstpflanzen"), iconFilename: "kunst"),
                AppSubNavigationItem(label: "Pflanzenschutz", i18nId: "header.nav.plants.protection", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzenschutz"), iconFilename: "Schutz"),
                AppSubNavigationItem(label: "Pflanzgefäße", i18nId: "header.nav.plants.planters", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzgefaesse"), iconFilename: "Topf"),
                AppSubNavigationItem(label: "Rankhilfen", i18nId: "header.nav.plants.trellises", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-rankhilfen"), iconFilename: "ranken"),
                AppSubNavigationItem(label: "Bewässerung", i18nId: "header.nav.plants.irrigation", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-bewaesserung"), iconFilename: "bewaesserung")
            ]
        ),

        // --- Kinderbereich ---
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/fuer-die-ganze-grossen"),
            label: "Kinderbereich", // GEÄNDERT
            i18nId: "header.nav.playfun",
            imageFilename: "cat_banner_spiel-spass.jpg",
            subItems: [
                AppSubNavigationItem(label: "Sandkästen", i18nId: "header.nav.playfun.sandpits", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-sandkasten"), iconFilename: "sandkasten"),
                AppSubNavigationItem(label: "Spielburgen", i18nId: "header.nav.playfun.playcastles", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-spielburgen"), iconFilename: "spielburgen"),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.playfun.swings", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-schaukeln"), iconFilename: "schukel"),
                AppSubNavigationItem(label: "Trampoline", i18nId: "header.nav.playfun.trampolines", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-trampoline"), iconFilename: "trampo"),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.playfun.accessories", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-zubehoer"), iconFilename: "trampozubehoer")
            ]
        )
    ]

    static func findItem(forMainCategorySlug slug: String) -> AppNavigationItem? {
        return items.first { $0.mainCategorySlug.lowercased() == slug.lowercased() }
    }
}
