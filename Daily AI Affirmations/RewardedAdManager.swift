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
    private let defaults = UserDefaults.standard
    private let policy = RewardedAdPolicy(openCountKey: "admob.rewarded.openCount")

    func appDidBecomeActive() {
        let action = policy.handleOpen(now: Date(), lastCountedAt: &lastCountedAt, defaults: defaults)
        switch action {
        case .ignore:
            return
        case .present:
            presentIfReady()
        case .load:
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

enum RewardedAdAction {
    case ignore
    case load
    case present
}

struct RewardedAdPolicy {
    let openCountKey: String
    let cooldown: TimeInterval = 1.0

    func handleOpen(now: Date, lastCountedAt: inout Date?, defaults: UserDefaults) -> RewardedAdAction {
        if let lastCountedAt, now.timeIntervalSince(lastCountedAt) < cooldown {
            return .ignore
        }

        lastCountedAt = now
        let nextCount = defaults.integer(forKey: openCountKey) + 1
        defaults.set(nextCount, forKey: openCountKey)
        return (nextCount % 5 == 0) ? .present : .load
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
