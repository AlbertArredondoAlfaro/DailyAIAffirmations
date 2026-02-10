//
//  NotificationSchedulerTests.swift
//  Daily AffirmationsTests
//
//  Created by Codex.
//

import XCTest
import UserNotifications
@testable import Daily_Affirmations

final class NotificationSchedulerTests: XCTestCase {
    func testSchedulesSevenDaysAtTenAM() {
        let defaults = UserDefaults(suiteName: "NotificationSchedulerTests")!
        defaults.removePersistentDomain(forName: "NotificationSchedulerTests")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let locale = Locale(identifier: "en_US")

        let manager = NotificationManager(
            center: .current(),
            calendar: calendar,
            locale: locale,
            defaults: defaults
        )

        let start = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 9))!
        let requests = manager.makeRequests(startingFrom: start, daysAhead: 7)

        XCTAssertEqual(requests.count, 7)
        for request in requests {
            let trigger = request.trigger as? UNCalendarNotificationTrigger
            let components = trigger?.dateComponents
            XCTAssertEqual(components?.hour, 10)
            XCTAssertEqual(components?.minute, 0)
            XCTAssertTrue(request.identifier.hasPrefix("daily-affirmation-"))
        }
    }

    func testUsesCustomNameWhenEnabled() {
        let defaults = UserDefaults(suiteName: "NotificationSchedulerTestsName")!
        defaults.removePersistentDomain(forName: "NotificationSchedulerTestsName")
        defaults.set("Alex", forKey: CustomizationDefaults.customNameKey)
        defaults.set(true, forKey: CustomizationDefaults.useNameKey)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let locale = Locale(identifier: "en_US")

        let manager = NotificationManager(
            center: .current(),
            calendar: calendar,
            locale: locale,
            defaults: defaults
        )

        let date = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10, hour: 9))!
        let requests = manager.makeRequests(startingFrom: date, daysAhead: 1)
        let body = requests.first?.content.body ?? ""

        let raw = AffirmationSelector.dailyAffirmation(
            for: date,
            language: .english,
            allowPlaceholders: true,
            calendar: calendar
        )
        let expected = raw.replacingOccurrences(of: "{name}", with: "Alex")
        XCTAssertEqual(body, expected)
    }
}
