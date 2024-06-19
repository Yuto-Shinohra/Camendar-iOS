//
//  CalendarView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct CalendarView: View {
    @State private var currentMonthIndex: Int
    @State private var selectedDate: SelectedDate? = nil
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
                                if let day = dateComponent.day {
                                    let isToday = Calendar.current.isDate(Date(), equalTo: Calendar.current.date(from: DateComponents(year: months[index].year, month: currentMonthIndex % 12 + 1, day: day))!, toGranularity: .day)
                                    ZStack {
                                        if selectedDate?.day == day && selectedDate?.month == currentMonthIndex % 12 + 1 && selectedDate?.year == months[index].year {
                                            Rectangle()
                                                .fill(Color.blue.opacity(0.3))
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(5)
                                        }
                                        
                                        Text("\(day)")
                                            .foregroundColor(isToday ? .green : .primary)
                                            .frame(width: 30, height: 30)
                                            .background(selectedDate?.day == day && selectedDate?.month == currentMonthIndex % 12 + 1 && selectedDate?.year == months[index].year ? Color.blue.opacity(0.3) : Color.clear)
                                            .cornerRadius(5)
                                            .onTapGesture {
                                                selectedDate = SelectedDate(day: day, month: currentMonthIndex % 12 + 1, year: months[index].year)
                                            }
                                    }
                                } else {
                                    Text("")
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
