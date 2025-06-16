import Foundation

struct AppNavigationData {
    // Diese private Funktion hilft uns, die Slugs aus den Links zu extrahieren.
    static private func extractSlug(from link: String, prefixToRemove: String) -> String {
        guard link.hasPrefix(prefixToRemove) else { return link }
        return String(link.dropFirst(prefixToRemove.count))
    }

    // Die Navigationsdaten, sorgfältig abgeglichen.
    // Die Struktur und Vollständigkeit kommt aus TypeScript,
    // die Slugs und Banner-Namen aus der bewährten Swift-Struktur.
    static let items: [AppNavigationItem] = [
        AppNavigationItem(
            mainCategorySlug: "gartenmoebel", // Aus alter Swift-Datei
            label: "Gartenmöbel", // Aus TS-Datei
            i18nId: "header.nav.furniture",
            imageFilename: "cat_banner_gartenmoebel", // Aus alter Swift-Datei
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
            mainCategorySlug: "sonnenschutz", // Aus alter Swift-Datei
            label: "Sonnenschutz", // Aus TS-Datei
            i18nId: "header.nav.sunprotection",
            imageFilename: "cat_banner_sonnenschutz", // Aus alter Swift-Datei
            subItems: [
                AppSubNavigationItem(label: "Markisen", i18nId: "header.nav.sunprotection.awnings", linkSlug: extractSlug(from: "/product-list/sonnenschutz-markisen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Sonnenschirme", i18nId: "header.nav.sunprotection.umbrellas", linkSlug: extractSlug(from: "/product-list/sonnenschutz-sonnenschirme", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.sunprotection.accessories", linkSlug: extractSlug(from: "/product-list/sonnenschutz-zubehoer", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "wasser-im-garten", // Aus alter Swift-Datei
            label: "Wasser im Garten", // Aus TS-Datei
            i18nId: "header.nav.water",
            imageFilename: "cat_banner_wasser_im_garten", // Aus alter Swift-Datei
            subItems: [
                AppSubNavigationItem(label: "Pools", i18nId: "header.nav.water.pools", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-pools", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Teichzubehör", i18nId: "header.nav.water.pondAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-teichzubehoer", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Poolzubehör", i18nId: "header.nav.water.poolAccessories", linkSlug: extractSlug(from: "/product-list/wasser-im-garten-poolzubehoer", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "heizen-feuer", // Aus alter Swift-Datei
            label: "Heizen & Feuer", // Aus TS-Datei
            i18nId: "header.nav.heating",
            imageFilename: "cat_banner_heizen_feuer", // Aus alter Swift-Datei
            subItems: [
                AppSubNavigationItem(label: "Kamine", i18nId: "header.nav.heating.fireplaces", linkSlug: extractSlug(from: "/product-list/heizen-feuer-kamine", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Feuerholzaufbewahrung", i18nId: "header.nav.heating.firewoodstorage", linkSlug: extractSlug(from: "/product-list/heizen-feuer-feuerholzaufbewahrung", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.heating.heaters", linkSlug: extractSlug(from: "/product-list/heizen-feuer-zubehoer", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "gartenhelfer-aufbewahrung", // Aus alter Swift-Datei
            label: "Gartenhelfer & Aufbewahrung", // Aus TS-Datei
            i18nId: "header.nav.gardenhelpers",
            imageFilename: "cat_banner_gartenhelfer", // KORRIGIERT: Kurzer Name aus alter Swift-Datei
            subItems: [
                AppSubNavigationItem(label: "Gartengeräte", i18nId: "header.nav.gardenhelpers.tools", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartengeraete", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartenschuppen", i18nId: "header.nav.gardenhelpers.sheds", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-gartenschuppen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Komposter", i18nId: "header.nav.gardenhelpers.composters", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-komposter", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Regentonnen", i18nId: "header.nav.gardenhelpers.waterbutts", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-regentonnen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartenwerkzeug", i18nId: "header.nav.gardenhelpers.toolstorage", linkSlug: extractSlug(from: "/product-list/gartenhelfer-aufbewahrung-werkzeug", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "deko-licht", // Aus alter Swift-Datei
            label: "Dekoration & Licht", // Aus TS-Datei
            i18nId: "header.nav.deco",
            imageFilename: "cat_banner_deko_licht", // Aus alter Swift-Datei
            subItems: [
                AppSubNavigationItem(label: "Gartenbeleuchtung", i18nId: "header.nav.deco.lighting", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenbeleuchtung", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartenlautsprecher", i18nId: "header.nav.deco.audio", linkSlug: extractSlug(from: "/product-list/deko-licht-audio", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartendeko", i18nId: "header.nav.deco.decoration", linkSlug: extractSlug(from: "/product-list/deko-licht-gartendeko", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Gartenteppiche", i18nId: "header.nav.deco.rugs", linkSlug: extractSlug(from: "/product-list/deko-licht-gartenteppiche", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Weihnachtsdeko", i18nId: "header.nav.deco.christmas", linkSlug: extractSlug(from: "/product-list/deko-licht-weihnachtsdeko", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "pflanzen-anzucht", // Aus alter Swift-Datei
            label: "Pflanzen & Anzucht", // Aus TS-Datei
            i18nId: "header.nav.plants",
            imageFilename: "cat_banner_pflanzen_anzucht", // Aus alter Swift-Datei
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
            mainCategorySlug: "fuer-die-ganze-grossen", // Aus alter Swift-Datei
            label: "Spiel & Spaß", // Aus TS-Datei
            i18nId: "header.nav.playfun",
            imageFilename: "cat_banner_spiel_spass", // Aus alter Swift-Datei
            subItems: [
                AppSubNavigationItem(label: "Sandkästen", i18nId: "header.nav.playfun.sandpits", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-sandkasten", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Spielburgen", i18nId: "header.nav.playfun.playcastles", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-spielburgen", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Schaukeln", i18nId: "header.nav.playfun.swings", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-schaukeln", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Trampoline", i18nId: "header.nav.playfun.trampolines", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-trampoline", prefixToRemove: "/product-list/")),
                AppSubNavigationItem(label: "Zubehör", i18nId: "header.nav.playfun.accessories", linkSlug: extractSlug(from: "/product-list/fuer-die-ganze-grossen-zubehoer", prefixToRemove: "/product-list/"))
            ]
        ),
        AppNavigationItem(
            mainCategorySlug: "grills-outdoor-kuechen",
            label: "Grills & Outdoor-Küchen",
            i18nId: "header.nav.grills",
            imageFilename: "cat_banner_grills_outdoor_kuechen",
            subItems: [
                AppSubNavigationItem(label: "Gasgrills", i18nId: "header.nav.grills.gas", linkSlug: "grills-gasgrills"),
                AppSubNavigationItem(label: "Holzkohlegrills", i18nId: "header.nav.grills.charcoal", linkSlug: "grills-holzkohlegrills"),
                AppSubNavigationItem(label: "Grillzubehör", i18nId: "header.nav.grills.accessories", linkSlug: "grills-zubehoer")
            ]
        )
    ]
}
