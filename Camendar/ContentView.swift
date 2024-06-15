//
//  ContentView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct ContentView: View {
    @State var isHome: Bool = true
    var body: some View{
        TabView{
            HomeView()
                .tabItem { Image(systemName: "house") }
                .tag(0)
            AddEventView()
                .tabItem { Image(systemName: "plus") }
                .tag(1)
            SettingsView()
                .tabItem { Image(systemName: "gearshape") }
                .tag(2)
        }
    }
}
