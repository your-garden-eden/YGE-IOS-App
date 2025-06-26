// DATEI: HomeTabView.swift
// PFAD: Features/Tabs/HomeTabView.swift
// VERSION: 1.0 (FINAL)

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
