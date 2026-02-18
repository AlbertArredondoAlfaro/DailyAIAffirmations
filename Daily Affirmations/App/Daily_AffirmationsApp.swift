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
        let adRequestConfiguration = MobileAds.shared.requestConfiguration
        adRequestConfiguration.maxAdContentRating = .parentalGuidance
        adRequestConfiguration.tagForChildDirectedTreatment = false
        adRequestConfiguration.tagForUnderAgeOfConsent = false
        
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
