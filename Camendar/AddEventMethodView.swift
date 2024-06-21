//
//  AddEventMethodView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct AddEventMethodView: View {
    @Environment(\.presentationMode) var presentationMode // For closing the view
    @State private var eventName: String = "" // Event name
    @State private var eventDate: Date // Event date
    @State private var startTime: Date // Start time
    @State private var endTime: Date // End time
    @State private var isAllDay: Bool = false // All-day event toggle
    var addEvent: (CalendarEvent) -> Void // Closure to add event
    
    // Initialize with selected date
    init(selectedDate: SelectedDate, addEvent: @escaping (CalendarEvent) -> Void) {
        self.addEvent = addEvent
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(
            year: selectedDate.year,
            month: selectedDate.month,
            day: selectedDate.day
        ))!
        
        self.eventDate = date
        self.startTime = date
        self.endTime = calendar.date(byAdding: .hour, value: 1, to: date)!
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Spacer()
                    TextField("Event Name...", text: $eventName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("All Day", isOn: $isAllDay)
                        .padding()
                    
                    if !isAllDay {
                        DatePicker(
                            "Start Time",
                            selection: $startTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .padding()
                        
                        DatePicker(
                            "End Time",
                            selection: $endTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .padding()
                    }
                    
                    Button(action: {
                        let event = CalendarEvent(
                            name: eventName,
                            date: eventDate,
                            startTime: isAllDay ? eventDate : startTime,
                            endTime: isAllDay ? eventDate : endTime,
                            isAllDay: isAllDay
                        )
                        addEvent(event)
                        saveEventToFirestore(event: event)
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Add Event")
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(10)
                            .font(.headline)
                    })
                }
            }
        }
    }
    
    private func saveEventToFirestore(event: CalendarEvent) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            try db.collection("users").document(userId).collection("events").document(event.id?.uuidString ?? UUID().uuidString).setData(event.toDictionary())
        } catch let error {
            print("Error writing event to Firestore: \(error)")
        }
    }
}
