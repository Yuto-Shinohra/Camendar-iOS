//
//  ContentView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
struct ContentView: View {
    @State var isHome: Bool = true
    @State var selectednum: Int = 0
    @State var selectedDate: SelectedDate? = nil
    @State private var events: [CalendarEvent] = []
    private let db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    
    var body: some View{
        VStack{
            if selectednum == 0 || selectednum == 1 {
                CalendarView(isSettings: false, selectedDate: $selectedDate)
            } else if selectednum == 2 {
                CalendarView(isSettings: true, selectedDate: $selectedDate)
            }
            TabView(selection: $selectednum){
                HomeView()
                    .tabItem { Image(systemName: "house") }
                    .tag(0)
                //                AddEventView()
                let calendar = Calendar.current
                let defaultDate = selectedDate ?? SelectedDate(
                    day: calendar.component(.day, from: Date()),
                    month: calendar.component(.month, from: Date()),
                    year: calendar.component(.year, from: Date())
                )
                AddEventMethodView(selectedDate: defaultDate, addEvent: { newEvent in
                    events.append(newEvent)
                    saveEventToFirestore(event: newEvent)
                    
                })
                .tabItem { Image(systemName: "plus") }
                .tag(1)
                SettingsView()
                    .tabItem { Image(systemName: "gearshape") }
                    .tag(2)
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
    
    private func loadEventsFromFirestore() {
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
