//
//  AddEventfromScannedDocumentView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI

struct AddEventfromScannedDocumentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var isScanDocument: Bool = true
    @State private var recognizedText: String = ""
    @State private var extractedDates: [(Date, String?, Date?, Date?)] = []
    @State private var simplifiedExtractedDates: [(Date, String?)] = []  // この変数をDocumentScanViewControllerRepresentableに渡す
    @State private var eventName: String = ""
    var addEvent: (CalendarEvent) -> Void
    @State private var startTime: Date
    @State private var endTime: Date

    init(selectedDate: SelectedDate, addEvent: @escaping (CalendarEvent) -> Void) {
        self.addEvent = addEvent
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(
            year: selectedDate.year,
            month: selectedDate.month,
            day: selectedDate.day
        ))!
        self.startTime = date
        self.endTime = calendar.date(byAdding: .hour, value: 24, to: date)!
    }

    var body: some View {
        VStack {
            List {
                ForEach(extractedDates.indices, id: \.self) { index in
                    VStack{
                        HStack {
                            TextField("イベント名...", text: bindingForDescription(at: index))
                            DatePicker(
                                "",
                                selection: $extractedDates[index].0,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                        }
                        HStack{
                            DatePicker(
                                "Start Time",
                                selection: bindingForStartTime(at: index),
                                displayedComponents: [.hourAndMinute]
                            )
                            .padding()

                            DatePicker(
                                "End Time",
                                selection: bindingForEndTime(at: index),
                                displayedComponents: [.hourAndMinute]
                            )
                            .padding()
                        }
                    }
                }
            }

            Button(action: {
                // スキャン処理前にデータを変換する必要はないため、この行を削除
                isScanDocument.toggle()
            }) {
                Text("Retake")
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(10)
                    .padding()
            }
            .sheet(isPresented: $isScanDocument, content: {
                DocumentScanViewControllerRepresentable(recognizedText: $recognizedText, extractedDates: $extractedDates) // 直接 extractedDates を使用
            })

            Button(action: {
                for eventData in extractedDates {
                    let newEvent = CalendarEvent(
                        name: eventData.1 ?? "新しいイベント",
                        date: eventData.0,
                        startTime: eventData.2 ?? eventData.0,
                        endTime: eventData.3 ?? Calendar.current.date(byAdding: .hour, value: 1, to: eventData.0)!
                    )
                    addEvent(newEvent)
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Add Events")
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(10)
                    .font(.headline)
            }
        }
    }

    func bindingForDescription(at index: Int) -> Binding<String> {
        return Binding<String>(
            get: {
                extractedDates[index].1 ?? ""
            },
            set: { newValue in
                extractedDates[index].1 = newValue.isEmpty ? nil : newValue
            }
        )
    }

    private func bindingForStartTime(at index: Int) -> Binding<Date> {
        Binding<Date>(
            get: {
                extractedDates[index].2 ?? self.startTime // オプショナルな開始時間がなければデフォルト値を使用
            },
            set: { newValue in
                extractedDates[index].2 = newValue
            }
        )
    }

    private func bindingForEndTime(at index: Int) -> Binding<Date> {
        Binding<Date>(
            get: {
                extractedDates[index].3 ?? self.endTime // オプショナルな終了時間がなければデフォルト値を使用
            },
            set: { newValue in
                extractedDates[index].3 = newValue
            }
        )
    }
}
