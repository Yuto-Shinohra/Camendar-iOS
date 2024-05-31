//
//  SelectedDate.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct SelectedDate: Identifiable, Equatable {
    var id = UUID() // ユニークIDp
    var day: Int // 日
    var month: Int // 月
    var year: Int // 年

    init(day: Int, month: Int, year: Int) { // day、month、yearを受け取るイニシャライザ
        self.day = day
        self.month = month
        self.year = year
    }
}
