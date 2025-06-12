// MARK: - ExpandableText.swift

import SwiftUI

struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    
    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false

    // Konfigurierbare Schriftarten und Farben, die zu deinem Design-System passen
    var font: Font = AppFonts.roboto(size: AppFonts.Size.body)
    var color: Color = AppColors.textMuted
    var buttonColor: Color = AppColors.primary

    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(font)
                .foregroundColor(color)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            determineTruncation(geometry: geometry)
                        }
                    }
                )
            
            if isTruncated {
                Button(action: {
                    withAnimation(.easeInOut) {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Weniger anzeigen" : "Mehr anzeigen")
                        .font(AppFonts.roboto(size: AppFonts.Size.caption, weight: .bold))
                        .foregroundColor(buttonColor)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func determineTruncation(geometry: GeometryProxy) {
        // Diese Methode berechnet die benötigte Höhe des gesamten Textes.
        let total = text.boundingRect(
            with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.roboto(size: AppFonts.Size.body)], // Hier muss die UIFont-Entsprechung hin
            context: nil
        )
        
        // Wenn die Gesamthöhe größer ist als die angezeigte Höhe, wird der Button eingeblendet.
        if total.size.height > geometry.size.height {
            self.isTruncated = true
        }
    }
}

// Diese Hilfs-Erweiterung wird für die `boundingRect`-Berechnung benötigt.
// Sie kann in einer geeigneten Hilfsdatei (z.B. `UIFont+Extensions.swift`) platziert werden.
fileprivate extension UIFont {
    static func roboto(size: CGFloat, weight: Weight = .regular) -> UIFont {
        // Passe die Font-Namen an, die du tatsächlich in deinem Projekt verwendest.
        let fontName: String
        switch weight {
        case .bold: fontName = "Roboto-Bold"
        case .semibold: fontName = "Roboto-Medium"
        default: fontName = "Roboto-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
