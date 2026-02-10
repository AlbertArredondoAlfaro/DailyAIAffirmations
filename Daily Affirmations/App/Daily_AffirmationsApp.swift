//
//  Daily_AffirmationsApp.swift
//  Daily Affirmations
//
//  Created by Albert Bit Dj on 5/2/26.
//

import SwiftUI
import GoogleMobileAds

@main
struct Daily_AffirmationsApp: App {
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
