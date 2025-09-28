//
//  Codepath_HW2App.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/16/25.
//

import SwiftUI
import ParseSwift

@main
struct Codepath_HW2App: App {
    init() {
        ParseSwift.initialize(
            applicationId: "YqQB6IixJqofkhv0o3YtWBFGnjcCx01GFYTlWg7K",
            clientKey: "FM22vBeSMsQwdQMVQ2Nd7KRFvl0Pgond8gSxlsEX",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
        }
    
    var body: some Scene {
        WindowGroup {
            if AppUser.current != nil {
                FeedView()
                    .task {
                        BeRealReminder.requestPermission()
                        let last = AppUser.current?.lastPostedAt
                        BeRealReminder.scheduleIfMissed(lastPostedAt: last, seconds: 60*30)
                    }
            } else {
                ContentView()
            }
        }
    }
}
