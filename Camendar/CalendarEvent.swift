//
//  CalendarEvent.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI
import FirebaseFirestore

struct CalendarEvent: Identifiable, Codable {
    var id: UUID?
    var name: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var isAllDay: Bool

    init(id: UUID? = UUID(), name: String, date: Date, startTime: Date, endTime: Date, isAllDay: Bool = false) {
        self.id = id
        self.name = name
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.isAllDay = isAllDay
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id?.uuidString ?? UUID().uuidString,
            "name": name,
            "date": Timestamp(date: date),
            "startTime": Timestamp(date: startTime),
            "endTime": Timestamp(date: endTime),
            "isAllDay": isAllDay
        ]
    }

    static func fromDictionary(_ dictionary: [String: Any]) -> CalendarEvent? {
        guard
            let idString = dictionary["id"] as? String,
            let id = UUID(uuidString: idString),
            let name = dictionary["name"] as? String,
            let date = dictionary["date"] as? Timestamp,
            let startTime = dictionary["startTime"] as? Timestamp,
            let endTime = dictionary["endTime"] as? Timestamp,
            let isAllDay = dictionary["isAllDay"] as? Bool
        else {
            return nil
        }

        return CalendarEvent(id: id, name: name, date: date.dateValue(), startTime: startTime.dateValue(), endTime: endTime.dateValue(), isAllDay: isAllDay)
    }
}
