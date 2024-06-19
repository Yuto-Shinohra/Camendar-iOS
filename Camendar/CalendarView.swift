//
//  CalendarView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentMonthIndex: Int
    @State private var currentYearIndex: Int
    let years: [Year] = generateYears(from: 2024, to: 2025)
    let isSettings: Bool
    @State var isMax: Bool = false
    
    init(isSettings: Bool) {
        self.isSettings = isSettings
        _isMax = State(initialValue: !isSettings)
        
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        var yearIndex = 0
        var monthIndex = 0
        
        for (index, year) in years.enumerated() {
            if year.year == currentYear {
                yearIndex = index
                break
            }
        }
        
        for (index, month) in years[yearIndex].months.enumerated() {
            if month.name == DateFormatter().monthSymbols[currentMonth - 1] {
                monthIndex = index
                break
            }
        }
        
        _currentYearIndex = State(initialValue: yearIndex)
        _currentMonthIndex = State(initialValue: monthIndex)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        if currentMonthIndex == 0 {
                            currentMonthIndex = 11
                            currentYearIndex = (currentYearIndex - 1 + years.count) % years.count
                        } else {
                            currentMonthIndex = (currentMonthIndex - 1 + years[currentYearIndex].months.count) % years[currentYearIndex].months.count
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text("\(years[currentYearIndex].months[currentMonthIndex].name) \(String(years[currentYearIndex].year))")
                    .font(.headline)
                    .onTapGesture {
                        withAnimation {
                            isMax.toggle()
                        }
                    }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        if currentMonthIndex == 11 {
                            currentMonthIndex = 0
                            currentYearIndex = (currentYearIndex + 1) % years.count
                        } else {
                            currentMonthIndex = (currentMonthIndex + 1) % years[currentYearIndex].months.count
                        }
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
                    ForEach(0..<years[currentYearIndex].months.count, id: \.self) { index in
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                            ForEach(years[currentYearIndex].months[index].days, id: \.self) { dateComponent in
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
