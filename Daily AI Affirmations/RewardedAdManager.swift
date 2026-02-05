//
//  RewardedAdManager.swift
//  Daily AI Affirmations
//
//  Created by Albert Bit Dj on 5/2/26.
//

import Foundation
import GoogleMobileAds
import UIKit

@MainActor
final class RewardedAdManager: NSObject {
    static let shared = RewardedAdManager()

    private var rewardedAd: RewardedAd?
    private var isLoading = false
    private var lastCountedAt: Date?
    private let openCountKey = "admob.rewarded.openCount"
    private let defaults = UserDefaults.standard

    func appDidBecomeActive() {
        if let lastCountedAt, Date().timeIntervalSince(lastCountedAt) < 1.0 {
            return
        }
        lastCountedAt = Date()

        let nextCount = defaults.integer(forKey: openCountKey) + 1
        defaults.set(nextCount, forKey: openCountKey)

        if nextCount % 5 == 0 {
            presentIfReady()
        } else {
            loadIfNeeded()
        }
    }

    private func loadIfNeeded() {
        guard rewardedAd == nil, !isLoading else { return }
        isLoading = true

        RewardedAd.load(with: AdMobConstants.rewardedAdUnitID, request: Request()) { [weak self] ad, _ in
            Task { [weak self] in
                guard let self else { return }
                await MainActor.run {
                    self.isLoading = false
                    if let ad {
                        ad.fullScreenContentDelegate = self
                        self.rewardedAd = ad
                    } else {
                        self.rewardedAd = nil
                    }
                }
            }
        }
    }

    private func presentIfReady() {
        guard let ad = rewardedAd else {
            loadIfNeeded()
            return
        }

        let rootViewController = Self.findRootViewController()
        do {
            try ad.canPresent(from: rootViewController)
        } catch {
            rewardedAd = nil
            loadIfNeeded()
            return
        }

        rewardedAd = nil
        ad.present(from: rootViewController) {
            // Reward granted by AdMob when user earns it.
        }
    }

    private static func findRootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

extension RewardedAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        loadIfNeeded()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        loadIfNeeded()
    }
}
