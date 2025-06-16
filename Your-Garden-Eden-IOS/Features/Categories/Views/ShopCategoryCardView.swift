import SwiftUI

struct ShopCategoryCardView: View {
    let category: WooCommerceCategory
    let displayName: String
    
    var body: some View {
        // FIX: Die ZStack enthält jetzt nur noch das Banner-Bild.
        // Der Text und der Farbverlauf wurden entfernt.
        ZStack {
            imageBanner
        }
        .frame(height: 150)
        .cornerRadius(AppStyles.BorderRadius.large)
        .clipped()
        .appShadow(AppStyles.Shadows.medium)
    }
    
    @ViewBuilder
    private var imageBanner: some View {
        // Die Logik zur Bildauswahl bleibt unverändert und ist korrekt.
        switch category.slug {
            // --- Hauptkategorien ---
        case "gartenmoebel": Image("cat_banner_gartenmoebel").resizable().aspectRatio(contentMode: .fill)
        case "sonnenschutz": Image("cat_banner_sonnenschutz").resizable().aspectRatio(contentMode: .fill)
        case "wasser-im-garten": Image("cat_banner_wasser_im_garten").resizable().aspectRatio(contentMode: .fill)
        case "heizen-feuer": Image("cat_banner_heizen_feuer").resizable().aspectRatio(contentMode: .fill)
        case "gartenhelfer-aufbewahrung": Image("cat_banner_gartenhelfer").resizable().aspectRatio(contentMode: .fill)
        case "deko-licht": Image("cat_banner_deko_licht").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht": Image("cat_banner_pflanzen_anzucht").resizable().aspectRatio(contentMode: .fill)
        case "fuer-die-ganze-grossen": Image("cat_banner_spiel_spass").resizable().aspectRatio(contentMode: .fill)
        case "grills-outdoor-kuechen": Image("cat_banner_grills_outdoor_kuechen").resizable().aspectRatio(contentMode: .fill)

            // --- Unterkategorien: Gartenmöbel ---
        case "gartenmoebel-sofas": Image("cat_banner_gartenmoebel-sofas").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-stuehle": Image("cat_banner_gartenmoebel-stuehle").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-hocker": Image("cat_banner_gartenmoebel-hocker").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-sitzpolster": Image("cat_banner_gartenmoebel-sitzpolster").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-tische": Image("cat_banner_gartenmoebel-tische").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-baenke": Image("cat_banner_gartenmoebel-baenke").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-liegen": Image("cat_banner_gartenmoebel-liegen").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-betten": Image("cat_banner_gartenmoebel-betten").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-haengematten": Image("cat_banner_gartenmoebel-haengematten").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-schaukeln": Image("cat_banner_gartenmoebel-schaukeln").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-schutzhuellen": Image("cat_banner_gartenmoebel-schutzhuellen").resizable().aspectRatio(contentMode: .fill)
        case "gartenmoebel-boxen": Image("cat_banner_gartenmoebel-boxen").resizable().aspectRatio(contentMode: .fill)
            
            // --- Unterkategorien: Sonnenschutz ---
        case "sonnenschutz-markisen": Image("cat_banner_sonnenschutz-markisen").resizable().aspectRatio(contentMode: .fill)
        case "sonnenschutz-sonnenschirme": Image("cat_banner_sonnenschutz-sonnenschirme").resizable().aspectRatio(contentMode: .fill)
        case "sonnenschutz-zubehoer": Image("cat_banner_sonnenschutz-zubehoer").resizable().aspectRatio(contentMode: .fill)

            // --- Unterkategorien: Wasser im Garten ---
        case "wasser-im-garten-pools": Image("cat_banner_wasser-im-garten-pools").resizable().aspectRatio(contentMode: .fill)
        case "wasser-im-garten-teichzubehoer": Image("cat_banner_wasser-im-garten-teichzubehoer").resizable().aspectRatio(contentMode: .fill)
        case "wasser-im-garten-poolzubehoer": Image("cat_banner_wasser-im-garten-poolzubehoer").resizable().aspectRatio(contentMode: .fill)

            // --- Unterkategorien: Heizen & Feuer ---
        case "heizen-feuer-kamine": Image("cat_banner_heizen-feuer-kamine").resizable().aspectRatio(contentMode: .fill)
        case "heizen-feuer-feuerholzaufbewahrung": Image("cat_banner_heizen-feuer-feuerholzaufbewahrung").resizable().aspectRatio(contentMode: .fill)
        case "heizen-feuer-zubehoer": Image("cat_banner_heizen-feuer-zubehoer").resizable().aspectRatio(contentMode: .fill)

            // --- Unterkategorien: Gartenhelfer & Aufbewahrung ---
        case "gartenhelfer-aufbewahrung-gartengeraete": Image("cat_banner_gartenhelfer-aufbewahrung-gartengeraete").resizable().aspectRatio(contentMode: .fill)
        case "gartenhelfer-aufbewahrung-gartenschuppen": Image("cat_banner_gartenhelfer-aufbewahrung-gartenschuppen").resizable().aspectRatio(contentMode: .fill)
        case "gartenhelfer-aufbewahrung-komposter": Image("cat_banner_gartenhelfer-aufbewahrung-komposter").resizable().aspectRatio(contentMode: .fill)
        case "gartenhelfer-aufbewahrung-regentonnen": Image("cat_banner_gartenhelfer-aufbewahrung-regentonnen").resizable().aspectRatio(contentMode: .fill)
        case "gartenhelfer-aufbewahrung-werkzeug": Image("cat_banner_gartenhelfer-aufbewahrung-werkzeug").resizable().aspectRatio(contentMode: .fill)

            // --- Unterkategorien: Deko & Licht ---
        case "deko-licht-gartenbeleuchtung": Image("cat_banner_deko-licht-gartenbeleuchtung").resizable().aspectRatio(contentMode: .fill)
        case "deko-licht-audio": Image("cat_banner_deko-licht-audio").resizable().aspectRatio(contentMode: .fill)
        case "deko-licht-gartendeko": Image("cat_banner_deko-licht-gartendeko").resizable().aspectRatio(contentMode: .fill)
        case "deko-licht-gartenteppiche": Image("cat_banner_deko-licht-gartenteppiche").resizable().aspectRatio(contentMode: .fill)
        case "deko-licht-weihnachtsdeko": Image("cat_banner_deko-licht-weihnachtsdeko").resizable().aspectRatio(contentMode: .fill)

            // --- Unterkategorien: Pflanzen & Anzucht ---
        case "pflanzen-anzucht-gewaechshaeuser": Image("cat_banner_pflanzen-anzucht-gewaechshaeuser").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht-hochbeet": Image("cat_banner_pflanzen-anzucht-hochbeet").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht-tische": Image("cat_banner_pflanzen-anzucht-tische").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht-staender": Image("cat_banner_pflanzen-anzucht-staender").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht-kunstpflanzen": Image("cat_banner_pflanzen-anzucht-kunstpflanzen").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht-pflanzenschutz": Image("cat_banner_pflanzen-anzucht-pflanzenschutz").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht-pflanzgefaesse": Image("cat_banner_pflanzen-anzucht-pflanzgefaesse").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-anzucht-rankhilfen": Image("cat_banner_pflanzen-anzucht-rankhilfen").resizable().aspectRatio(contentMode: .fill)
        case "pflanzen-ansucht-bewaesserung": Image("cat_banner_pflanzen-ansucht-bewaesserung").resizable().aspectRatio(contentMode: .fill)

            // --- Unterkategorien: Spiel & Spaß ---
        case "fuer-die-ganze-grossen-sandkasten": Image("cat_banner_fuer-die-ganze-grossen-sandkasten").resizable().aspectRatio(contentMode: .fill)
        case "fuer-die-ganze-grossen-spielburgen": Image("cat_banner_fuer-die-ganze-grossen-spielburgen").resizable().aspectRatio(contentMode: .fill)
        case "fuer-die-ganze-grossen-schaukeln": Image("cat_banner_fuer-die-ganze-grossen-schaukeln").resizable().aspectRatio(contentMode: .fill)
        case "fuer-die-ganze-grossen-trampoline": Image("cat_banner_fuer-die-ganze-grossen-trampoline").resizable().aspectRatio(contentMode: .fill)
        case "fuer-die-ganze-grossen-zubehoer": Image("cat_banner_fuer-die-ganze-grossen-zubehoer").resizable().aspectRatio(contentMode: .fill)

            // --- Unterkategorien: Grills & Outdoor-Küchen ---
        case "grills-gasgrills": Image("cat_banner_grills-gasgrills").resizable().aspectRatio(contentMode: .fill)
        case "grills-holzkohlegrills": Image("cat_banner_grills-holzkohlegrills").resizable().aspectRatio(contentMode: .fill)
        case "grills-zubehoer": Image("cat_banner_grills-zubehoer").resizable().aspectRatio(contentMode: .fill)
            
        default:
            if let apiImageURL = category.image?.src.asURL() {
                AsyncImage(url: apiImageURL) { phase in
                    if let image = phase.image { image.resizable().aspectRatio(contentMode: .fill) }
                    else { placeholderView }
                }
            } else { placeholderView }
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            AppColors.backgroundLightGray
            Image(systemName: "photo.fill").font(.largeTitle).foregroundColor(AppColors.textMuted.opacity(0.3))
        }
    }
}
