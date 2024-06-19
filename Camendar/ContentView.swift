//
//  ContentView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct ContentView: View {
    @State var isHome: Bool = true
    @State var selectednum: Int = 0
    @State var selectedDate: SelectedDate? = nil
    
    var body: some View{
        VStack{
            if selectednum == 0 || selectednum == 1 {
                CalendarView(isSettings: false, selectedDate: $selectedDate)
            } else if selectednum == 2 {
                CalendarView(isSettings: true, selectedDate: $selectedDate)
            }
            TabView(selection: $selectednum){
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
}
