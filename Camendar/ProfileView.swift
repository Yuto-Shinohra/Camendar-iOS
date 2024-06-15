//
//  ProfileView.swift
//  CamendarUITests
//
//  Created by Yuto Shinohara on 2024/05/30.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    var body: some View {
        Button(action: {
            do {
                try Auth.auth().signOut()
            }
            catch let error as NSError {
                print(error)
            }
        }, label: {
            Text("SignOut")
        })
    }
}
