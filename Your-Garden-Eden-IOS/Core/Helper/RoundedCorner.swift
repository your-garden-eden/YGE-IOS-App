//
//  RoundedCorner.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 18.06.25.
//


// DATEI: View+CornerRadius.swift
// PFAD: Core/UI/Extensions/View+CornerRadius.swift
// ZWECK: Eine Hilfserweiterung, die es erlaubt, nur bestimmte Ecken einer View abzurunden.

import SwiftUI

public extension View {
    /// Rundet nur die spezifizierten Ecken einer View ab.
    /// - Parameters:
    ///   - radius: Der Radius der Abrundung.
    ///   - corners: Die Ecken, die abgerundet werden sollen (z.B. `.topLeft`, `.bottomRight`).
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

/// Eine `Shape`-Struktur, die ein Rechteck mit abgerundeten Ecken nach Vorgabe zeichnet.
private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}