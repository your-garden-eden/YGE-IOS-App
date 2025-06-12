//
//  SelectedTabKey.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 12.06.25.
//


//
//  EnvironmentValues+Extensions.swift
//  Your-Garden-Eden-IOS
//
//  Created by ... // Dein Erstellungsdatum
//

import SwiftUI

// --- START: DEFINITION DES ENVIRONMENT KEYS ---
// Dies ist die formale Definition unseres benutzerdefinierten Environment Keys.
// Der Compiler benötigt diesen Code, um den Key-Path `\.selectedTab` in der CartView
// auflösen zu können.

// 1. Definiere den Key selbst.
// Er speichert eine Bindung (@Binding) zu einer Ganzzahl (Int), die den ausgewählten Tab repräsentiert.
private struct SelectedTabKey: EnvironmentKey {
    // Der Standardwert ist eine konstante Bindung auf 0 (den ersten Tab).
    static var defaultValue: Binding<Int> = .constant(0)
}

// 2. Erweitere die `EnvironmentValues` von SwiftUI.
// Dies macht den Key über den `\.`-Syntax zugänglich (`\.selectedTab`).
extension EnvironmentValues {
    var selectedTab: Binding<Int> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}
// --- ENDE: DEFINITION DES ENVIRONMENT KEYS ---