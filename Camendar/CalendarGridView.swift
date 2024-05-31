//
//  CalendarGridView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct CalendarGridView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: SelectedDate?
    var events: [CalendarEvent] // イベントのリスト

    var body: some View {
        let gridItem = GridItem(.flexible(), spacing: 10)
        let daysInWeek = ["日", "月", "火", "水", "木", "金", "土"]

        VStack {
            HStack {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))

            LazyVGrid(columns: Array(repeating: gridItem, count: 7), spacing: 10) {
                ForEach(daysInMonth(currentMonth), id: \.self) { dateComponent in
                    GridItemView(
                        dateComponent: dateComponent,
                        currentMonth: currentMonth,
                        selectedDate: $selectedDate,
                        events: events // イベントのリストを渡す
                    )
                }
            }
        }
    }

    func daysInMonth(_ currentMonth: Date) -> [DateComponent] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        let firstDayWeekday = calendar.component(.weekday, from: monthStart)
        let numberOfDays = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0

        var days = [DateComponent]()

        for _ in 1..<firstDayWeekday {
            days.append(DateComponent(day: nil, isPlaceholder: true))
        }

        for day in 1...numberOfDays {
            days.append(DateComponent(day: day, isPlaceholder: false))
        }

        return days
    }
}
