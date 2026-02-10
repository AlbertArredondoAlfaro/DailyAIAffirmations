//
//  CustomizationDefaults.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import Foundation

enum CustomizationDefaults {
    static let appGroupId = "group.com.idreamstudios.dailyaffirmations"
    static let customNameKey = "customName"
    static let useNameKey = "useCustomName"

    static var sharedDefaults: UserDefaults {
        let shared = UserDefaults(suiteName: appGroupId) ?? .standard
        migrateIfNeeded(into: shared)
        return shared
    }

    private static func migrateIfNeeded(into shared: UserDefaults) {
        let hasName = shared.object(forKey: customNameKey) != nil
        let hasUseName = shared.object(forKey: useNameKey) != nil
        guard !hasName && !hasUseName else { return }

        let standard = UserDefaults.standard
        if let name = standard.string(forKey: customNameKey) {
            shared.set(name, forKey: customNameKey)
        }
        if standard.object(forKey: useNameKey) != nil {
            shared.set(standard.bool(forKey: useNameKey), forKey: useNameKey)
        }
    }
}
