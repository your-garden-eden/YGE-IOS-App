import SwiftUI

struct SubCategoryRow: View {
    let subCategory: DisplayableSubCategory

    var body: some View {
        HStack(spacing: 15) {
            iconView
                .frame(width: 40, height: 40)
                .background(AppColors.backgroundLightGray)
                .clipShape(Circle())
            
            Text(subCategory.label)
                .font(.body)
                .foregroundStyle(AppColors.textBase)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textMuted.opacity(0.7))
        }
        .padding(.vertical, 8)
        .background(.clear)
    }

    /// Diese View wählt das korrekte Icon basierend auf dem `label` der Unterkategorie aus.
    @ViewBuilder
    private var iconView: some View {
        if let iconName = iconName(for: subCategory.label) {
            Image(iconName)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "tag.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(AppColors.textMuted)
                .padding(10)
        }
    }
    
    /// Ordnet einem Label-String manuell einen Asset-Namen zu.
    /// WICHTIG: Die 'case'-Strings müssen exakt mit den Kategorie-Namen aus WooCommerce übereinstimmen.
    private func iconName(for label: String) -> String? {
        switch label {
            case "Sofas": return "Gatensofas"
            case "Stühle": return "GartenSessel"
            case "Hocker": return "hocker"
            case "Sitzpolster": return "polster"
            case "Gartentische": return "Tsch"
            case "Bänke": return "Bank"
            case "Liegen": return "Sonnenliege"
            case "Betten": return "Bett"
            case "Hängematten": return "haengmatte"
            case "Gartenmöbel Schaukeln", "Schaukeln": return "Hollywood"
            case "Schutzhüllen": return "Schutzhuelle"
            case "Boxen": return "gartenbox"
            case "Markisen": return "Markise"
            case "Sonnenschirme": return "Sonnenschirm"
            case "Pools": return "Pool"
            case "Teichzubehör": return "teichzubehoer"
            case "Poolzubehör": return "pollzubehoer"
            case "Kamine": return "Feuer"
            case "Feuerholzaufbewahrung": return "Holz"
            case "Gartengeräte": return "Maeher"
            case "Gartenschuppen": return "schuppen"
            case "Komposter": return "BIO"
            case "Regentonnen": return "regentonne"
            case "Gartenwerkzeug": return "werkzeug"
            case "Gartenbeleuchtung": return "Lampe"
            case "Gartenlautsprecher": return "audio"
            case "Gartendeko": return "Deko"
            case "Gartenteppiche": return "Teppich"
            case "Weihnachtsdeko": return "weihnacht"
            case "Gewächshäuser": return "Gewaechs"
            case "Hochbeete": return "gatenbox"
            case "Tische": return "planztisch"
            case "Ständer": return "staender"
            case "Kunstpflanzen": return "kunst"
            case "Pflanzenschutz": return "Schutz"
            case "Pflanzgefäße": return "Topf"
            case "Rankhilfen": return "ranken"
            case "Bewässerung": return "bewaesserung"
            case "Sandkästen": return "sandkasten"
            case "Spielburgen": return "spielburgen"
            case "Trampoline": return "trampo"
            case "Zubehör": return "schrimzubehoer"
            default: return nil
        }
    }
}
