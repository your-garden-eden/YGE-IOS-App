//
//  ShopTabView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 20.06.25.
//


// DATEI: ShopTabView.swift
// PFAD: Views/Tabs/ShopTabView.swift
// ZWECK: Dient als Navigations-Host für den "Shop"-Tab.
//        Nimmt einen Binding zum Navigationspfad entgegen, um ein Zurücksetzen
//        durch die übergeordnete ContentView zu ermöglichen.

import SwiftUI

struct ShopTabView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            ShopView()
                .withAppNavigation()
        }
    }
}