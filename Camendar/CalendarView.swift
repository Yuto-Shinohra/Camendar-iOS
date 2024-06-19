//
//  CalendarView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: SelectedDate?
    @State private var currentMonthIndex: Int
    @State private var currentYear: Int
    let isSettings: Bool
    @State var isMax: Bool = false
    
    init(isSettings: Bool, selectedDate: Binding<SelectedDate?>) {
        self.isSettings = isSettings
        self._selectedDate = selectedDate
        _isMax = State(initialValue: !isSettings)
        
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        _currentYear = State(initialValue: currentYear)
        _currentMonthIndex = State(initialValue: currentMonth - 1)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if currentMonthIndex == 0 {
                            currentMonthIndex = 11
                            currentYear -= 1
                        } else {
                            currentMonthIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text("\(monthName(for: currentMonthIndex)) \(String(currentYear))")
                    .font(.headline)
                    .onTapGesture {
                        withAnimation {
                            isMax.toggle()
                        }
                    }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if currentMonthIndex == 11 {
                            currentMonthIndex = 0
                            currentYear += 1
                        } else {
                            currentMonthIndex += 1
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
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(generateDays(for: currentMonthIndex + 1, year: currentYear), id: \.self) { dateComponent in
                        if let day = dateComponent.day {
                            let isToday = Calendar.current.isDate(Date(), equalTo: Calendar.current.date(from: DateComponents(year: currentYear, month: currentMonthIndex + 1, day: day))!, toGranularity: .day)
                            ZStack {
                                if selectedDate?.day == day && selectedDate?.month == currentMonthIndex + 1 && selectedDate?.year == currentYear {
                                    Rectangle()
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 30, height: 30)
                                        .cornerRadius(5)
                                }
                                
                                Text("\(day)")
                                    .foregroundColor(isToday ? .green : .primary)
                                    .frame(width: 30, height: 30)
                                    .background(selectedDate?.day == day && selectedDate?.month == currentMonthIndex + 1 && selectedDate?.year == currentYear ? Color.blue.opacity(0.3) : Color.clear)
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        selectedDate = SelectedDate(day: day, month: currentMonthIndex + 1, year: currentYear)
                                    }
                            }
                        } else {
                            Text("")
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .padding()
                .transition(.opacity)
                Spacer()
            }
        }
    }
    
    func monthName(for index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(year: 2020, month: index + 1))!
        return dateFormatter.string(from: date)
    }
}
