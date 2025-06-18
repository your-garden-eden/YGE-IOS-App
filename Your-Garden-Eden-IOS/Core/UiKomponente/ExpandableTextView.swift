//
//  ExpandableTextView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: ExpandableTextView.swift
// PFAD: Core/UI/Components/ExpandableTextView.swift
// ZWECK: Eine wiederverwendbare View, die langen Text anzeigt und bei Bedarf
//        eine "Mehr anzeigen" / "Weniger anzeigen" Schaltfläche einblendet.

import SwiftUI
import UIKit

public struct ExpandableTextView: View {
    private let text: String
    private let lineLimit: Int
    
    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false

    private var font: Font
    private var color: Color
    private var buttonColor: Color

    public init(text: String, lineLimit: Int = 5) {
        // HTML-Tags werden direkt bei der Initialisierung entfernt, um eine saubere Logik zu gewährleisten.
        self.text = text.strippingHTML()
        self.lineLimit = lineLimit
        // Standardwerte werden aus dem zentralen AppTheme bezogen.
        self.font = AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.body)
        self.color = AppTheme.Colors.textMuted
        self.buttonColor = AppTheme.Colors.primary
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(font)
                .foregroundColor(color)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    // Ein unsichtbarer Text im Hintergrund dient der Größenmessung, um festzustellen, ob der Text abgeschnitten ist.
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
                        .font(AppTheme.Fonts.roboto(size: AppTheme.Fonts.Size.caption, weight: .bold))
                        .foregroundColor(buttonColor)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func determineTruncation(geometry: GeometryProxy) {
        // Nutzt UIKit-Methoden, um die exakte Höhe des vollständigen Textes zu berechnen.
        let uiFont = UIFont.roboto(size: AppTheme.Fonts.Size.body)
        
        let totalRect = text.boundingRect(
            with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: uiFont],
            context: nil
        )
        
        // Wenn die berechnete Höhe größer ist als die tatsächlich verfügbare Höhe der View,
        // wird der Text abgeschnitten (truncated).
        if totalRect.size.height > geometry.size.height {
            self.isTruncated = true
        }
    }
}