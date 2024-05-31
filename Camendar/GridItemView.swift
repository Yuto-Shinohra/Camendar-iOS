//
//  GridItemView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct GridItemView: View {
    let dateComponent: DateComponent
    let currentMonth: Date
    @Binding var selectedDate: SelectedDate?
    var events: [CalendarEvent] // イベントのリスト

    // 日付が選択されているかどうかを確認
    var isSelected: Bool {
        if let selected = selectedDate {
            if let day = dateComponent.day {
                let calendar = Calendar.current
                let month = calendar.component(.month, from: currentMonth)
                let year = calendar.component(.year, from: currentMonth)

                return selected.day == day && selected.month == month && selected.year == year
            }
        }
        return false
    }
    var isToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let day = dateComponent.day {
            let monthComponents = calendar.dateComponents([.year, .month], from: currentMonth)
            let baseDate = calendar.date(from: monthComponents)
            let correctDate = calendar.date(byAdding: .day, value: day - 1, to: baseDate!)

            return calendar.isDate(today, inSameDayAs: correctDate!)
        }
        return false
    }

    //イベントがあるかどうか
    var hasEvent: Bool {
        let calendar = Calendar.current
        if let day = dateComponent.day {
            let monthComponents = calendar.dateComponents([.year, .month], from: currentMonth)
            let baseDate = calendar.date(from: monthComponents)
            let correctDate = calendar.date(byAdding: .day, value: day - 1, to: baseDate!)
            return events.contains { event in
                calendar.isDate(event.date, inSameDayAs: correctDate!)
            }
        }
        return false
    }


    var body: some View {
        Button(action: {
            if let day = dateComponent.day {
                let calendar = Calendar.current
                let month = calendar.component(.month, from: currentMonth)
                let year = calendar.component(.year, from: currentMonth)

                selectedDate = SelectedDate(
                    day: day,
                    month: month,
                    year: year
                )
            }
        }) {
            VStack {
                Text(dateComponent.day != nil ? "\(dateComponent.day!)" : "")
                    .foregroundColor(isSelected ? .white : .black) // 選択された日付の文字色
                if hasEvent {
                    Image(systemName: "flag")
                        .foregroundColor(isSelected ? .white : .black) // 選択された日付の文字色
                }
            }
            .frame(width: 45, height: 40) // 固定サイズ
            .background(
                isSelected
                ? Color(red: 0.2, green: 0.2, blue: 0.9,opacity: 1)// 選択された日付の背景色
                :isToday
                ?Color.green.opacity(0.3)
                : dateComponent.isPlaceholder
                ? Color.clear
                : Color.blue.opacity(0.3) // それ以外の背景色
            )
            .cornerRadius(8) // 角を丸める
            .shadow(radius: 10)
        }
        .buttonStyle(PlainButtonStyle()) // デフォルトのボタンスタイル
    }
}
