//
//  AdMobManager.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import AppTrackingTransparency
import Foundation
import GoogleMobileAds

@MainActor
final class AdMobManager: ObservableObject {
    static let shared = AdMobManager()

    private let trackingManager: TrackingAuthorizationManager
    private var hasStarted = false

    init(trackingManager: TrackingAuthorizationManager = .shared) {
        self.trackingManager = trackingManager
    }

    func startIfNeeded() async {
        if #available(iOS 14, *) {
            if trackingManager.status == .notDetermined {
                await trackingManager.requestIfNeeded()
            }
        }

        guard trackingManager.canRequestAds else { return }
        guard !hasStarted else { return }

        let config = MobileAds.shared.requestConfiguration
        config.maxAdContentRating = .pg
        config.tagForChildDirectedTreatment = false
        config.tagForUnderAgeOfConsent = false

        MobileAds.shared.start(completionHandler: nil)
        hasStarted = true
    }

    func makeRequest() -> Request {
        AdRequestFactory.make(isPersonalizedAllowed: trackingManager.isPersonalizedAdsAllowed)
    }
}

enum AdRequestFactory {
    static func make(isPersonalizedAllowed: Bool) -> Request {
        let request = Request()
        if !isPersonalizedAllowed {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        return request
    }
}
