//
//  Month.swift
//  Camendar_UITest
//
//  Created by Yuto Shinohara on 2024/06/14.
//

import SwiftUI

//struct Month {
//    let name: String
//    let year: Int
//    let days: [DateComponent]
//}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
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
