//
//  CamendarApp.swift
//  Camendar
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()

    return true
  }
}

@main
struct camendarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var isHome: Bool = false
    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser != nil {
                ContentView(isaddEvent: false,isHome: $isHome)
            }else{
                AuthView()
            }
        }
    }
}
