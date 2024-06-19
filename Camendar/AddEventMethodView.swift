//
//  AddEventMethodView.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI
struct AddEventMethodView: View {
    @Environment(\.presentationMode) var presentationMode // 画面を閉じるため
    @State private var eventName: String = "" // イベント名
    @State private var eventDate: Date // イベントの日付
    @State private var startTime: Date // 開始時間
    @State private var endTime: Date // 終了時間
    var addEvent: (CalendarEvent) -> Void // イベントを追加するためのクロージャ
    
    // 初期日付を選択された日付から生成
    init(selectedDate: SelectedDate, addEvent: @escaping (CalendarEvent) -> Void) {
        self.addEvent = addEvent
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(
            year: selectedDate.year,
            month: selectedDate.month,
            day: selectedDate.day
        ))!
        
        self.eventDate = date // イベントの日付
        self.startTime = date // 開始時間を設定
        self.endTime = calendar.date(byAdding: .hour, value: 1, to: date)! // 終了時間を1時間後に設定
    }
    //イベントを追加する日付が今日よりも前の場合はアラートを表示
    var body: some View {
        VStack{
            Divider()
            ScrollView{
                VStack {
                    Spacer()
                    TextField("Event Name...", text: $eventName) // イベント名の入力
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // 日付を選択するためのDatePicker
                    DatePicker(
                        "Event Date",
                        selection: $eventDate,
                        displayedComponents: [.date]
                    )
                    .padding()
                    
                    // 開始時間と終了時間の選択
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
                    Button(action: {
                        let event = CalendarEvent(
                            name: eventName,
                            date: eventDate, // イベントの日付
                            startTime: startTime,
                            endTime: endTime
                        )
                        addEvent(event) // イベントを追加
                        presentationMode.wrappedValue.dismiss() // 画面を閉じる
                        print(CalendarEvent.self)
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
        //        .padding()
    }
}
