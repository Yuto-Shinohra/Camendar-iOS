//
//  Month.swift
//  Camendar_UITest
//
//  Created by Yuto Shinohara on 2024/06/14.
//

import SwiftUI

struct Month {
    let name: String
    let days: [DateComponent]
}

struct Year {
    let year: Int
    let months: [Month]
}

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

func generateMonths(for year: Int) -> [Month] {
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM"
    
    var months = [Month]()
    
    for month in 1...12 {
        let startComponents = DateComponents(year: year, month: month, day: 1)
        guard let startDate = calendar.date(from: startComponents) else { continue }
        
        let days = generateDays(for: month, year: year)
        let monthName = dateFormatter.string(from: startDate)
        months.append(Month(name: monthName, days: days))
    }
    
    return months
}

func generateYears(from startYear: Int, to endYear: Int) -> [Year] {
    var years = [Year]()
    
    for year in startYear...endYear {
        let months = generateMonths(for: year)
        years.append(Year(year: year, months: months))
    }
    
    return years
}
