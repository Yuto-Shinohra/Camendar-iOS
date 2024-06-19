//
//  CalendarView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentMonthIndex: Int = 0
    let months: [Month] = generateMonths(for: 2024)
    let isSettings: Bool
    @State var isMax: Bool = false
    init(isSettings: Bool) {
            self.isSettings = isSettings
            _isMax = State(initialValue: !isSettings)
        }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        currentMonthIndex = (currentMonthIndex - 1 + months.count) % months.count
                    }
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text("\(months[currentMonthIndex].name) 2024")
                    .font(.headline)
                    .onTapGesture {
                        withAnimation{
                            isMax.toggle()
                        }
                    }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        currentMonthIndex = (currentMonthIndex + 1) % months.count
                    }
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            if isMax{
                HStack {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding([.leading, .trailing])
                
                TabView(selection: $currentMonthIndex) {
                    ForEach(0..<months.count, id: \.self) { index in
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                            ForEach(months[index].days, id: \.self) { day in
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .tag(index)
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                Spacer()
            }
        }
        
    }
}
