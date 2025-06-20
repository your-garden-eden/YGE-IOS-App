//
//  HomeTabView.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 20.06.25.
//


// DATEI: HomeTabView.swift
// PFAD: Views/Tabs/HomeTabView.swift
// ZWECK: Dient als Navigations-Host für den "Home"-Tab.
//        Nimmt einen Binding zum Navigationspfad entgegen, um ein Zurücksetzen
//        durch die übergeordnete ContentView zu ermöglichen.

import SwiftUI

struct HomeTabView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .withAppNavigation()
        }
    }
}