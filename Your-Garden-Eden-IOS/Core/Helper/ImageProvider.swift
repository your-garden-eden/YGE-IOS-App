// DATEI: ImageProvider.swift
// PFAD: Helper/ImageProvider.swift
// VERSION: 1.0 (VOLLSTÄNDIG & FINAL)
// ZWECK: Eine zentrale Dienstklasse zur dynamischen Bereitstellung von lokalen Bildern.
//        Verhindert, dass Views Kenntnis über spezifische Asset-Namen haben müssen.

import SwiftUI

/// Stellt eine zentrale Logik zur Verfügung, um Bilder basierend auf Geschäftslogik (z.B. Kategorie-Slugs) bereitzustellen.
public struct ImageProvider {
    
    /// Gibt das passende Banner-Bild für einen gegebenen Kategorie-Slug zurück.
    /// Dies ist die einzige Stelle im Code, die diese Zuordnung kennt.
    /// - Parameter slug: Der `slug` der WooCommerce-Kategorie.
    /// - Returns: Ein `Image`-Objekt, falls ein passendes lokales Asset gefunden wurde, sonst `nil`.
    public static func banner(forCategorySlug slug: String) -> Image? {
        switch slug {
            // --- Hauptkategorien ---
        case "gartenmoebel": return Image("cat_banner_gartenmoebel")
        case "sonnenschutz": return Image("cat_banner_sonnenschutz")
        case "wasser-im-garten": return Image("cat_banner_wasser_im_garten")
        case "heizen-feuer": return Image("cat_banner_heizen_feuer")
        case "gartenhelfer-aufbewahrung": return Image("cat_banner_gartenhelfer")
        case "deko-licht": return Image("cat_banner_deko_licht")
        case "pflanzen-anzucht": return Image("cat_banner_pflanzen_anzucht")
        case "fuer-die-ganze-grossen": return Image("cat_banner_spiel_spass")
        case "grills-outdoor-kuechen": return Image("cat_banner_grills_outdoor_kuechen")

            // --- Unterkategorien: Gartenmöbel ---
        case "gartenmoebel-sofas": return Image("cat_banner_gartenmoebel_sofas")
        case "gartenmoebel-stuehle": return Image("cat_banner_gartenmoebel_stuehle")
        case "gartenmoebel-hocker": return Image("cat_banner_gartenmoebel_hocker")
        case "gartenmoebel-sitzpolster": return Image("cat_banner_gartenmoebel_sitzpolster")
        case "gartenmoebel-tische": return Image("cat_banner_gartenmoebel_tische")
        case "gartenmoebel-baenke": return Image("cat_banner_gartenmoebel_baenke")
        case "gartenmoebel-liegen": return Image("cat_banner_gartenmoebel_liegen")
        case "gartenmoebel-betten": return Image("cat_banner_gartenmoebel_betten")
        case "gartenmoebel-haengematten": return Image("cat_banner_gartenmoebel_haengematten")
        case "gartenmoebel-schaukeln": return Image("cat_banner_gartenmoebel_schaukeln")
        case "gartenmoebel-schutzhuellen": return Image("cat_banner_gartenmoebel_schutzhuellen")
        case "gartenmoebel-boxen": return Image("cat_banner_gartenmoebel_boxen")
            
            // --- Unterkategorien: Sonnenschutz ---
        case "sonnenschutz-markisen": return Image("cat_banner_sonnenschutz_markisen")
        case "sonnenschutz-sonnenschirme": return Image("cat_banner_sonnenschutz_sonnenschirme")
        case "sonnenschutz-zubehoer": return Image("cat_banner_sonnenschutz_zubehoer")

            // --- Unterkategorien: Wasser im Garten ---
        case "wasser-im-garten-pools": return Image("cat_banner_wasser_im_garten_pools")
        case "wasser-im-garten-teichzubehoer": return Image("cat_banner_wasser_im_garten_teichzubehoer")
        case "wasser-im-garten-poolzubehoer": return Image("cat_banner_wasser_im_garten_poolzubehoer")

            // --- Unterkategorien: Heizen & Feuer ---
        case "heizen-feuer-kamine": return Image("cat_banner_heizen_feuer_kamine")
        case "heizen-feuer-feuerholzaufbewahrung": return Image("cat_banner_heizen_feuer_feuerholzaufbewahrung")
        case "heizen-feuer-zubehoer": return Image("cat_banner_heizen_feuer_zubehoer")

            // --- Unterkategorien: Gartenhelfer & Aufbewahrung ---
        case "gartenhelfer-aufbewahrung-gartengeraete": return Image("cat_banner_gartenhelfer_aufbewahrung_gartengeraete")
        case "gartenhelfer-aufbewahrung-gartenschuppen": return Image("cat_banner_gartenhelfer_aufbewahrung_gartenschuppen")
        case "gartenhelfer-aufbewahrung-komposter": return Image("cat_banner_gartenhelfer_aufbewahrung_komposter")
        case "gartenhelfer-aufbewahrung-regentonnen": return Image("cat_banner_gartenhelfer_aufbewahrung_regentonnen")
        case "gartenhelfer-aufbewahrung-werkzeug": return Image("cat_banner_gartenhelfer_aufbewahrung_werkzeug")

            // --- Unterkategorien: Deko & Licht ---
        case "deko-licht-gartenbeleuchtung": return Image("cat_banner_deko_licht_gartenbeleuchtung")
        case "deko-licht-audio": return Image("cat_banner_deko_licht_audio")
        case "deko-licht-gartendeko": return Image("cat_banner_deko_licht_gartendeko")
        case "deko-licht-gartenteppiche": return Image("cat_banner_deko_licht_gartenteppiche")
        case "deko-licht-weihnachtsdeko": return Image("cat_banner_deko_licht_weihnachtsdeko")

            // --- Unterkategorien: Pflanzen & Anzucht ---
        case "pflanzen-anzucht-gewaechshaeuser": return Image("cat_banner_pflanzen_anzucht_gewaechshaeuser")
        case "pflanzen-anzucht-hochbeet": return Image("cat_banner_pflanzen_anzucht_hochbeet")
        case "pflanzen-anzucht-tische": return Image("cat_banner_pflanzen_anzucht_tische")
        case "pflanzen-anzucht-staender": return Image("cat_banner_pflanzen_anzucht_staender")
        case "pflanzen-anzucht-kunstpflanzen": return Image("cat_banner_pflanzen_anzucht_kunstpflanzen")
        case "pflanzen-anzucht-pflanzenschutz": return Image("cat_banner_pflanzen_anzucht_pflanzenschutz")
        case "pflanzen-anzucht-pflanzgefaesse": return Image("cat_banner_pflanzen_anzucht_pflanzgefaesse")
        case "pflanzen-anzucht-rankhilfen": return Image("cat_banner_pflanzen_anzucht_rankhilfen")
        case "pflanzen-ansucht-bewaesserung": return Image("cat_banner_pflanzen_ansucht_bewaesserung")

            // --- Unterkategorien: Spiel & Spaß ---
        case "fuer-die-ganze-grossen-sandkasten": return Image("cat_banner_fuer_die_ganze_grossen_sandkasten")
        case "fuer-die-ganze-grossen-spielburgen": return Image("cat_banner_fuer_die_ganze_grossen_spielburgen")
        case "fuer-die-ganze-grossen-schaukeln": return Image("cat_banner_fuer_die_ganze_grossen_schaukeln")
        case "fuer-die-ganze-grossen-trampoline": return Image("cat_banner_fuer_die_ganze_grossen_trampoline")
        case "fuer-die-ganze-grossen-zubehoer": return Image("cat_banner_fuer_die_ganze_grossen_zubehoer")

            // --- Unterkategorien: Grills & Outdoor-Küchen ---
       
            
        // Wenn kein lokales Bild für den Slug definiert ist, wird nil zurückgegeben.
        // Die aufrufende View kann dann auf ein API-Bild oder einen Platzhalter ausweichen.
        default:
            return nil
        }
    }
}
