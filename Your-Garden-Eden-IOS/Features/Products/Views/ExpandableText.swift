// Path: Your-Garden-Eden-IOS/Features/Common/Views/ExpandableText.swift

import SwiftUI

struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    
    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false

    var font: Font
    var color: Color
    var buttonColor: Color

    init(text: String, lineLimit: Int = 5) {
        // HTML-Stripping direkt im Initializer für saubere Logik
        self.text = text.strippingHTML()
        self.lineLimit = lineLimit
        // Standardwerte aus unserem Design-System
        self.font = AppFonts.roboto(size: AppFonts.Size.body)
        self.color = AppColors.textMuted
        self.buttonColor = AppColors.primary
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(font)
                .foregroundColor(color)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    // Versteckter Text im Hintergrund, um die Größe zu messen
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
        let uiFont = UIFont.roboto(size: AppFonts.Size.body)
        
        let total = text.boundingRect(
            with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: uiFont],
            context: nil
        )
        
        if total.size.height > geometry.size.height {
            self.isTruncated = true
        }
    }
}

// Diese Hilfs-Erweiterung wird für die `boundingRect`-Berechnung benötigt.
// Idealerweise liegt sie in einer eigenen Datei `UIFont+Extensions.swift` im Core/Extensions Ordner.
fileprivate extension UIFont {
    static func roboto(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String
        switch weight {
        case .bold: fontName = "Roboto-Bold"
        case .medium: fontName = "Roboto-Medium" // SwiftUI's .semibold entspricht oft .medium in Font-Files
        default: fontName = "Roboto-Regular"
        }
        // Fallback auf System-Font, falls der Custom-Font nicht geladen wurde.
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
