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
    @State private var selectedWeekday: Int? = nil // State to track the selected weekday
    var events: [CalendarEvent] // List of events
    @Environment(\.colorScheme) private var colorScheme

    init(isSettings: Bool, selectedDate: Binding<SelectedDate?>, events: [CalendarEvent]) {
        self.isSettings = isSettings
        self._selectedDate = selectedDate
        self.events = events
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
            // Top bar
            HStack {
                Button(action: {
                    previousMonth()
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text("\(monthName(for: currentMonthIndex)) \(String(currentYear))")
                    .font(.headline)
                    .onTapGesture {
                        isMax.toggle()
                    }
                
                Spacer()
                
                Button(action: {
                    nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Condensed view
            if isMax {
                HStack {
                    ForEach(0..<7, id: \.self) { index in
                        let day = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index]
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .background(selectedWeekday == index ? Color.blue.opacity(0.3) : Color.clear)
                            .cornerRadius(5)
                            .onTapGesture {
                                selectedWeekday = index
                                selectedDate = nil // Clear date selection
                            }
                    }
                }
                .padding([.leading, .trailing])
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(generateDays(for: currentMonthIndex + 1, year: currentYear), id: \.self) { dateComponent in
                        if let day = dateComponent.day {
                            let date = Calendar.current.date(from: DateComponents(year: currentYear, month: currentMonthIndex + 1, day: day))!
                            let isToday = Calendar.current.isDate(Date(), equalTo: date, toGranularity: .day)
                            let isSelected = selectedDate?.day == day && selectedDate?.month == currentMonthIndex + 1 && selectedDate?.year == currentYear
                            let isSelectedWeekday = selectedWeekday != nil && Calendar.current.component(.weekday, from: date) - 1 == selectedWeekday
                            let hasEvents = events.contains { event in
                                Calendar.current.isDate(event.date, inSameDayAs: date)
                            }
                            ZStack {
                                if isSelected || (selectedWeekday != nil && isSelectedWeekday) {
                                    Rectangle()
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 30, height: 30)
                                        .cornerRadius(5)
                                }
                                
                                Text("\(day)")
                                    .foregroundColor(isToday ? .green : .primary)
                                    .frame(width: 30, height: 30)
                                    .background(isSelected || (selectedWeekday != nil && isSelectedWeekday) ? Color.blue.opacity(0.3) : Color.clear)
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        selectedDate = SelectedDate(day: day, month: currentMonthIndex + 1, year: currentYear)
                                        selectedWeekday = nil // Clear weekday selection
                                    }
                                
                                if hasEvents {
                                    Image(systemName: "flag")
                                        .font(.system(size: 9))
                                        .frame(width: 5, height: 5)
                                        .offset(x: 10, y: -10)
                                }
                            }
                        } else {
                            Text("")
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .padding()
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < 0 {
                                nextMonth()
                            } else if value.translation.width > 0 {
                                previousMonth()
                            }
                        }
                )
//                Spacer()
                Button(action: {
                    isMax.toggle()
                }, label: {
                    Image(systemName: "arrow.up")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                })
            }else{
                Button(action: {
                    isMax.toggle()
                }, label: {
                    Image(systemName: "arrow.down")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                })
            }
            Divider()
        }
    }

    func monthName(for index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(year: 2020, month: index + 1))!
        return dateFormatter.string(from: date)
    }

    func nextMonth() {
        if currentMonthIndex == 11 {
            currentMonthIndex = 0
            currentYear += 1
        } else {
            currentMonthIndex += 1
        }
    }

    func previousMonth() {
        if currentMonthIndex == 0 {
            currentMonthIndex = 11
            currentYear -= 1
        } else {
            currentMonthIndex -= 1
        }
    }

    func generateDays(for month: Int, year: Int) -> [DateComponent] {
        var dateComponents: [DateComponent] = []
        let calendar = Calendar.current
        let dateComponentsDate = DateComponents(year: year, month: month)
        guard let firstDayOfMonth = calendar.date(from: dateComponentsDate),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        for _ in 0..<firstWeekday {
            dateComponents.append(DateComponent(day: nil, isPlaceholder: true))
        }
        
        for day in range {
            dateComponents.append(DateComponent(day: day, isPlaceholder: false))
        }
        
        return dateComponents
    }
}
