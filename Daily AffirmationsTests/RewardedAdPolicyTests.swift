//
//  RewardedAdPolicyTests.swift
//  Daily AffirmationsTests
//
//  Created by Codex.
//

import Foundation
import Testing
@testable import Daily_Affirmations

struct RewardedAdPolicyTests {
    @Test func firstOpenLoads() {
        let defaults = UserDefaults(suiteName: "RewardedAdPolicyTests.first")!
        defaults.removePersistentDomain(forName: "RewardedAdPolicyTests.first")
        var lastCountedAt: Date?
        let policy = RewardedAdPolicy(openCountKey: "openCount")

        let action = policy.handleOpen(now: Date(), lastCountedAt: &lastCountedAt, defaults: defaults)

        #expect(action == .load)
        #expect(defaults.integer(forKey: "openCount") == 1)
    }

    @Test func everyFifthOpenPresents() {
        let defaults = UserDefaults(suiteName: "RewardedAdPolicyTests.fifth")!
        defaults.removePersistentDomain(forName: "RewardedAdPolicyTests.fifth")
        defaults.set(4, forKey: "openCount")
        var lastCountedAt: Date?
        let policy = RewardedAdPolicy(openCountKey: "openCount")

        let action = policy.handleOpen(now: Date(), lastCountedAt: &lastCountedAt, defaults: defaults)

        #expect(action == .present)
        #expect(defaults.integer(forKey: "openCount") == 5)
    }

    @Test func cooldownIgnoresRapidOpen() {
        let defaults = UserDefaults(suiteName: "RewardedAdPolicyTests.cooldown")!
        defaults.removePersistentDomain(forName: "RewardedAdPolicyTests.cooldown")
        var lastCountedAt: Date? = Date()
        let policy = RewardedAdPolicy(openCountKey: "openCount")

        let action = policy.handleOpen(now: Date(), lastCountedAt: &lastCountedAt, defaults: defaults)

        #expect(action == .ignore)
        #expect(defaults.integer(forKey: "openCount") == 0)
    }
}
