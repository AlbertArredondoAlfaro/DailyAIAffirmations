//
//  TrackingAuthorizationManager.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import AppTrackingTransparency
import Combine
import Foundation

@MainActor
final class TrackingAuthorizationManager: ObservableObject {
    static let shared = TrackingAuthorizationManager()

    @Published private(set) var status: ATTrackingManager.AuthorizationStatus

    private let defaults: UserDefaults

    private enum Keys {
        static let requested = "att.requested"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if #available(iOS 14, *) {
            self.status = ATTrackingManager.trackingAuthorizationStatus
        } else {
            self.status = .authorized
        }
    }

    var canRequestAds: Bool {
        if #available(iOS 14, *) {
            return status != .notDetermined
        }
        return true
    }

    var isPersonalizedAdsAllowed: Bool {
        if #available(iOS 14, *) {
            return status == .authorized
        }
        return true
    }

    func requestIfNeeded() async {
        guard #available(iOS 14, *) else {
            status = .authorized
            return
        }
        guard status == .notDetermined else { return }
        defaults.set(true, forKey: Keys.requested)
        let newStatus = await ATTrackingManager.requestTrackingAuthorization()
        status = newStatus
    }

    func refreshStatus() {
        if #available(iOS 14, *) {
            status = ATTrackingManager.trackingAuthorizationStatus
        } else {
            status = .authorized
        }
    }
}
