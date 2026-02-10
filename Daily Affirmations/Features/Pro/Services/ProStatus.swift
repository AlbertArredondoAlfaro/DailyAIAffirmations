//
//  ProStatus.swift
//  Daily Affirmations
//
//  Created by Codex.
//

import Foundation

enum ProStatus {
    private static let key = "app.pro.enabled"
    static let productId = "com.idreamstudios.dailyaffirmations.pro"

    static var isPro: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

enum ProNotifications {
    static let rewardedAdDidClose = Notification.Name("rewardedAdDidClose")
}
