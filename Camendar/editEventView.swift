//
//  editEventView.swift
//  CamendarUITests
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct editEventView: View {
    @State private var eventName: String
    @State private var eventDate: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @Binding var events: [CalendarEvent]
    let eventID: UUID
    var addEvent: (CalendarEvent) -> Void // イベントを追加するためのクロージャ

    @Environment(\.dismiss) private var dismiss

    // Explicit internal initializer
    init(eventName: String, eventDate: Date, startTime: Date, endTime: Date, events: Binding<[CalendarEvent]>, eventID: UUID, addEvent: @escaping (CalendarEvent) -> Void) {
        _eventName = State(initialValue: eventName)
        _eventDate = State(initialValue: eventDate)
        _startTime = State(initialValue: startTime)
        _endTime = State(initialValue: endTime)
        _events = events
        self.eventID = eventID
        self.addEvent = addEvent
    }

    var body: some View {
        VStack {
            TextField("Event Name...", text: $eventName) // イベント名の入力
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            DatePicker(
                "Event Date",
                selection: $eventDate,
                displayedComponents: [.date]
            )
            .padding()
            DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                .padding()

            DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                .padding()
            Button(action: {
                let event = CalendarEvent(id: eventID, name: eventName, date: eventDate, startTime: startTime, endTime: endTime)
                deleteEvent()
                addEvent(event)
            }, label: {
                Text("Change Event Details")
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(10)
                    .padding()
            })
        }
        .navigationBarItems(trailing: Button(action: {
            deleteEvent()
            dismiss()

        }, label: {

            Text("Delete")
                .foregroundColor(.red)
        }))
    }

    func deleteEvent() {
        events.removeAll { $0.id == eventID }
    }
}
