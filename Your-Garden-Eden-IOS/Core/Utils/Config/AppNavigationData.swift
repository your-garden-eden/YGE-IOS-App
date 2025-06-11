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

    // KORREKTUR: Alle 'iconFilename'-Parameter wurden aus den Initialisierungen entfernt, um den Compiler-Fehler zu beheben.
    static let items: [AppNavigationItem] = [
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/gartenmoebel"), label: "Gartenmöbel", i18nId: "header.nav.furniture", imageFilename: "cat_banner_gartenmoebel.jpg",
            subItems: [
                AppSubNavigationItem(label: "Sofas", i18nId: "header.nav.furniture.sofas", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sofas")),
                AppSubNavigationItem(label: "Stühle", i18nId: "header.nav.furniture.chairs", linkSlug: extractSlug(from: "/product-list/gartenmoebel-stuehle")),
                AppSubNavigationItem(label: "Hocker", i18nId: "header.nav.furniture.stools", linkSlug: extractSlug(from: "/product-list/gartenmoebel-hocker")),
                AppSubNavigationItem(label: "Sitzpolster", i18nId: "header.nav.furniture.seatingGroups", linkSlug: extractSlug(from: "/product-list/gartenmoebel-sitzpolster")),
                AppSubNavigationItem(label: "Gartentische", i18nId: "header.nav.furniture.tables", linkSlug: extractSlug(from: "/product-list/gartenmoebel-tische")),
                AppSubNavigationItem(label: "Bänke", i18nId: "header.nav.furniture.benches", linkSlug: extractSlug(from: "/product-list/gartenmoebel-baenke")),
                AppSubNavigationItem(label: "Liegen", i18nId: "header.nav.furniture.sunloungers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-liegen")),
                AppSubNavigationItem(label: "Betten", i18nId: "header.nav.furniture.beds", linkSlug: extractSlug(from: "/product-list/gartenmoebel-betten")),
                AppSubNavigationItem(label: "Hängematten", i18nId: "header.nav.furniture.hammocks", linkSlug: extractSlug(from: "/product-list/gartenmoebel-haengematten")),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.furniture.swings", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schaukeln")),
                AppSubNavigationItem(label: "Schutzhüllen", i18nId: "header.nav.furniture.covers", linkSlug: extractSlug(from: "/product-list/gartenmoebel-schutzhuellen")),
                AppSubNavigationItem(label: "Boxen", i18nId: "header.nav.furniture.box", linkSlug: extractSlug(from: "/product-list/gartenmoebel-boxen"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/sonnenschutz"), label: "Sonnenschutz", i18nId: "header.nav.sunprotection", imageFilename: "cat_banner_sonnenschutz.jpg",
            subItems: [
                AppSubNavigationItem(label: "Markisen", i18nId: "header.nav.sunprotection.awnings", linkSlug: extractSlug(from: "/product-list/sonnenschutz-markisen")),
                AppSubNavigationItem(label: "Sonnenschirme", i18nId: "header.nav.sunprotection.umbrellas", linkSlug: extractSlug(from: "/product-list/sonnenschutz-sonnenschirme")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.sunprotection.accessories", linkSlug: extractSlug(from: "/product-list/sonnenschutz-zubehoer"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/wasser-im-garten"), label: "Wasser im Garten", i18nId: "header.nav.water", imageFilename: "cat_banner_wasser-im-garten.jpg",
            subItems: [
                AppSubNavigationItem(label: "Pools", i18nId: "header.nav.water.pools", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-pools")),
                AppSubNavigationItem(label: "Teichzubehör", i18nId: "header.nav.water.pondAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-teichzubehoer")),
                AppSubNavigationItem(label: "Poolzubehör", i18nId: "header.nav.water.poolAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-poolzubehoer"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/heizen-feuer"), label: "Heizen-Feuer", i18nId: "header.nav.heating", imageFilename: "cat_banner_heizen-feuer.jpg",
            subItems: [
                AppSubNavigationItem(label: "Kamine", i18nId: "header.nav.heating.fireplaces", linkSlug: extractSlug(from: "/product-list/heizen-feuer-kamine")),
                AppSubNavigationItem(label: "Feuerholzaufbewahrung", i18nId: "header.nav.heating.firewoodstorage", linkSlug: extractSlug(from: "/product-list/heizen-feuer-feuerholzaufbewahrung")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.heating.heaters", linkSlug: extractSlug(from: "/product-list/heizen-feuer-zubehoer"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/gartenhelfer-aufbewahrung"), label: "Gartenhelfer-Aufbewahrung", i18nId: "header.nav.gardenhelpers", imageFilename: "cat_banner_gartenhelfer.jpg",
            subItems: [
                AppSubNavigationItem(label: "Gartengeräte", i18nId: "header.nav.gardenhelpers.tools", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartengeraete")),
                AppSubNavigationItem(label: "Gartenschuppen", i18nId: "header.nav.gardenhelpers.sheds", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartenschuppen")),
                AppSubNavigationItem(label: "Komposter", i18nId: "header.nav.gardenhelpers.composters", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-komposter")),
                AppSubNavigationItem(label: "Regentonnen", i18nId: "header.nav.gardenhelpers.waterbutts", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-regentonnen")),
                AppSubNavigationItem(label: "Gartenwerkzeug", i18nId: "header.nav.gardenhelpers.toolstorage", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-werkzeug"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/deko-licht"), label: "Deko-Licht", i18nId: "header.nav.deco", imageFilename: "cat_banner_deko-licht.jpg",
            subItems: [
                AppSubNavigationItem(label: "Gartenbeleuchtung", i18nId: "header.nav.deco.lighting", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenbeleuchtung")),
                AppSubNavigationItem(label: "Gartenlautsprecher", i18nId: "header.nav.deco.audio", linkSlug: extractSlug(from: "/product-list/deko-licht-audio")),
                AppSubNavigationItem(label: "Gartendeko", i18nId: "header.nav.deco.decoration", linkSlug: extractSlug(from: "/product-list/deko-licht-gartendeko")),
                AppSubNavigationItem(label: "Gartenteppiche", i18nId: "header.nav.deco.rugs", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenteppiche")),
                AppSubNavigationItem(label: "Weihnachtsdeko", i18nId: "header.nav.deco.christmas", linkSlug: extractSlug(from: "/product-list/deko-licht-weihnachtsdeko"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/pflanzen-anzucht"), label: "Pflanzen-Anzucht", i18nId: "header.nav.plants", imageFilename: "cat_banner_pflanzen-anzucht.jpg",
            subItems: [
                AppSubNavigationItem(label: "Gewächshäuser", i18nId: "header.nav.plants.greenhouses", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-gewaechshaeuser")),
                AppSubNavigationItem(label: "Hochbeete", i18nId: "header.nav.plants.raisedbeds", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-hochbeet")),
                AppSubNavigationItem(label: "Tische", i18nId: "header.nav.plants.tables", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-tische")),
                AppSubNavigationItem(label: "Ständer", i18nId: "header.nav.plants.stands", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-staender")),
                AppSubNavigationItem(label: "Kunstpflanzen", i18nId: "header.nav.plants.artificial", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-kunstpflanzen")),
                AppSubNavigationItem(label: "Pflanzenschutz", i18nId: "header.nav.plants.protection", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzenschutz")),
                AppSubNavigationItem(label: "Pflanzgefäße", i18nId: "header.nav.plants.planters", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-pflanzgefaesse")),
                AppSubNavigationItem(label: "Rankhilfen", i18nId: "header.nav.plants.trellises", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-rankhilfen")),
                AppSubNavigationItem(label: "Bewässerung", i18nId: "header.nav.plants.irrigation", linkSlug: extractSlug(from: "/product-list/pflanzen-anzucht-bewaesserung"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: extractSlug(from: "/category/fuer-die-ganze-grossen"), label: "Kinderbereich", i18nId: "header.nav.playfun", imageFilename: "cat_banner_spiel-spass.jpg",
            subItems: [
                AppSubNavigationItem(label: "Sandkästen", i18nId: "header.nav.playfun.sandpits", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-sandkasten")),
                AppSubNavigationItem(label: "Spielburgen", i18nId: "header.nav.playfun.playcastles", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-spielburgen")),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.playfun.swings", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-schaukeln")),
                AppSubNavigationItem(label: "Trampoline", i18nId: "header.nav.playfun.trampolines", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-trampoline")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.playfun.accessories", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-zubehoer"))
            ]
        )
    ]

    static func findItem(forMainCategorySlug slug: String) -> AppNavigationItem? {
        return items.first { $0.mainCategorySlug.lowercased() == slug.lowercased() }
    }
}
