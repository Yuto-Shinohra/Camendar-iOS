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
    @State private var isAllDay: Bool // New state for the all-day toggle
    @Binding var events: [CalendarEvent]
    let eventID: UUID
    var addEvent: (CalendarEvent) -> Void // Closure to add event

    @Environment(\.dismiss) private var dismiss

    // Explicit internal initializer
    init(eventName: String, eventDate: Date, startTime: Date, endTime: Date, isAllDay: Bool, events: Binding<[CalendarEvent]>, eventID: UUID, addEvent: @escaping (CalendarEvent) -> Void) {
        _eventName = State(initialValue: eventName)
        _eventDate = State(initialValue: eventDate)
        _startTime = State(initialValue: startTime)
        _endTime = State(initialValue: endTime)
        _isAllDay = State(initialValue: isAllDay)
        _events = events
        self.eventID = eventID
        self.addEvent = addEvent
    }

    var body: some View {
        ScrollView {
            VStack {
                TextField("Event Name...", text: $eventName) // Event name input
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                DatePicker(
                    "Event Date",
                    selection: $eventDate,
                    displayedComponents: [.date]
                )
                .padding()
                
                Toggle("All Day", isOn: $isAllDay)
                    .padding()
                
                if !isAllDay {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                        .padding()
                    
                    DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                        .padding()
                }

                Button(action: {
                    let event = CalendarEvent(id: eventID, name: eventName, date: eventDate, startTime: isAllDay ? eventDate : startTime, endTime: isAllDay ? eventDate : endTime, isAllDay: isAllDay)
                    deleteEvent()
                    addEvent(event)
                    dismiss() // Dismiss the view after adding the event
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
    }

    func deleteEvent() {
        events.removeAll { $0.id == eventID }
    }
}
