//
//  Month.swift
//  Camendar_UITest
//
//  Created by Yuto Shinohara on 2024/06/14.
//

import SwiftUI

// Helper functions and data models
struct Month {
    let name: String
    let days: [Date]
}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
}

func generateDays(for month: Int, year: Int) -> [Date] {
    var dates: [Date] = []
    let calendar = Calendar.current
    let dateComponents = DateComponents(year: year, month: month)
    if let date = calendar.date(from: dateComponents),
       let range = calendar.range(of: .day, in: .month, for: date) {
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: date) {
                dates.append(dayDate)
            }
        }
    }
    return dates
}
func generateMonths(for year: Int) -> [Month] {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM"
    
    var months = [Month]()
    
    for month in 1...12 {
        let startComponents = DateComponents(year: year, month: month, day: 1)
        guard let startDate = calendar.date(from: startComponents) else { continue }
        
        var days = [Date]()
        var currentDate = startDate
        while calendar.component(.month, from: currentDate) == month {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        let monthName = dateFormatter.string(from: startDate)
        months.append(Month(name: monthName, days: days))
    }
    
    return months
}
