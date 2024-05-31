//
//  DateComponent.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import Foundation

struct DateComponent: Identifiable, Hashable {
    let id = UUID()
    let day: Int?
    let isPlaceholder: Bool
}
