//
//  CalendarView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI


struct CalendarView: View {
    @State private var currentMonth: Date = Date() // 現在の月
    @Binding var selectedDate: SelectedDate? // 選択された日付
    var events: [CalendarEvent] // イベントのリスト
    @State private var recognizedText: String = "" // OCR結果を保持

    var body: some View {
        VStack {
            //            Text(monthYearString(date: currentMonth))
            //                .font(.title)
            //                .bold()
            //                .padding()

            CalendarGridView(
                currentMonth: $currentMonth,
                selectedDate: $selectedDate,
                events: events // イベントのリストを渡す
            )
            .navigationBarTitle(monthYearString(date: currentMonth),displayMode: .inline)

            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            withAnimation {
                                currentMonth = addMonth(to: currentMonth, offset: 1)
                            }
                        } else if value.translation.width > 0 {
                            withAnimation {
                                currentMonth = addMonth(to: currentMonth, offset: -1)
                            }
                        }
                    }
            )
        }
    }
    func monthYearString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
    func addMonth(to date: Date, offset: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: offset, to: date) ?? date
    }
}
