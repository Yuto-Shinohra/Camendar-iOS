//
//  CalendarView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentMonthIndex: Int
    let months: [Month] = generateMonths(from: 2024, to: 2025)
    let isSettings: Bool
    @State var isMax: Bool = false
    
    init(isSettings: Bool) {
        self.isSettings = isSettings
        _isMax = State(initialValue: !isSettings)
        
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        let initialMonthIndex = (currentYear - 2024) * 12 + (currentMonth - 1)
        _currentMonthIndex = State(initialValue: initialMonthIndex)
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
                
                Text("\(months[currentMonthIndex].name) \(String(months[currentMonthIndex].year))")
                    .font(.headline)
                    .onTapGesture {
                        withAnimation {
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
            
            if isMax {
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
                            ForEach(months[index].days, id: \.self) { dateComponent in
                                if dateComponent.isPlaceholder {
                                    Text("")
                                        .frame(width: 30, height: 30)
                                } else {
                                    Text("\(dateComponent.day!)")
                                        .frame(width: 30, height: 30)
                                }
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
