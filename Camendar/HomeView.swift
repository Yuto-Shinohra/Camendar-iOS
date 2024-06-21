//
//  HomeView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/06/14.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct HomeView: View {
    @Binding var selectedDate: SelectedDate?
    @State var isaddEvent: Bool = false
    @State private var events: [CalendarEvent] = []
    @State var ShowCamera: Bool = false
    @State var iseditEvent: Bool = false
    @State var isProfile: Bool = false

    private let db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    var body: some View {
        NavigationView {
            VStack {
                if let selectedDate = selectedDate {
                    let relatedEvents = events.filter { event in
                        let calendar = Calendar.current
                        let eventDate = calendar.dateComponents([.year, .month, .day], from: event.date)
                        return eventDate.year == selectedDate.year &&
                        eventDate.month == selectedDate.month &&
                        eventDate.day == selectedDate.day
                    }
                    VStack {
                        if relatedEvents.isEmpty {
                            Text("No Event")
                                .padding()
                        } else {
                            List {
                                ForEach(relatedEvents) { event in
                                    HStack {
                                        if event.isAllDay {
                                            Text("All Day")
                                        } else {
                                            Text("\(timeFormatter.string(from: event.startTime))~\(timeFormatter.string(from: event.endTime))")
                                        }
                                        NavigationLink(destination: editEventView(
                                            eventName: event.name,
                                            eventDate: event.date,
                                            startTime: event.startTime,
                                            endTime: event.endTime,
                                            isAllDay: event.isAllDay,
                                            events: $events,
                                            eventID: event.id ?? UUID(),
                                            addEvent: { updatedEvent in
                                                if let index = events.firstIndex(where: { $0.id == updatedEvent.id }) {
                                                    events[index] = updatedEvent
                                                } else {
                                                    events.append(updatedEvent)
                                                }
                                                saveEventToFirestore(event: updatedEvent)
                                            }
                                        )) {
                                            Text(event.name)
                                                .padding(.horizontal)
                                                .padding(.vertical, 4)
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                                }
                                .onDelete(perform: remove)
                            }
                            .scrollContentBackground(.hidden)
                        }
                    }
                } else {
                    Text("Select a date to see events")
                        .padding()
                }
                Spacer()
            }
            .onAppear {
                loadEventsFromFirestore()
            }
            .onChange(of: selectedDate) { newSelectedDate in
                loadEventsFromFirestore(for: newSelectedDate)
            }
        }
    }

    private func saveEventToFirestore(event: CalendarEvent) {
        guard let userId = userId else { return }
        do {
            try db.collection("users").document(userId).collection("events").document(event.id?.uuidString ?? UUID().uuidString).setData(event.toDictionary())
        } catch let error {
            print("Error writing event to Firestore: \(error)")
        }
    }

    private func loadEventsFromFirestore(for selectedDate: SelectedDate? = nil) {
        guard let userId = userId else { return }
        db.collection("users").document(userId).collection("events").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting events from Firestore: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    self.events = querySnapshot.documents.compactMap { document in
                        CalendarEvent.fromDictionary(document.data())
                    }
                }
                if let selectedDate = selectedDate {
                    self.events = self.events.filter { event in
                        let calendar = Calendar.current
                        let eventDate = calendar.dateComponents([.year, .month, .day], from: event.date)
                        return eventDate.year == selectedDate.year &&
                        eventDate.month == selectedDate.month &&
                        eventDate.day == selectedDate.day
                    }
                }
            }
        }
    }

    private func remove(at offsets: IndexSet) {
        guard let userId = userId else { return }
        offsets.forEach { idx in
            let event = events[idx]
            db.collection("users").document(userId).collection("events").document(event.id?.uuidString ?? UUID().uuidString).delete()
        }
        events.remove(atOffsets: offsets)
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}
