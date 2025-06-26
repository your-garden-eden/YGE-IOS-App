// DATEI: ShopTabView.swift
// PFAD: Features/Tabs/ShopTabView.swift
// VERSION: 1.0 (FINAL)

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
