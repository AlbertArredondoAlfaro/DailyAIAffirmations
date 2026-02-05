//
//  WidgetTimelineHelperTests.swift
//  Daily AI AffirmationsTests
//
//  Created by Codex.
//

import Foundation
import Testing
@testable import Daily_AI_Affirmations

struct WidgetTimelineHelperTests {
    @Test func nextRefreshDateIsStartOfTomorrow() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let date = calendar.date(from: DateComponents(year: 2026, month: 5, day: 12, hour: 14, minute: 30))!

        let nextRefresh = WidgetTimelineHelper.nextRefreshDate(from: date, calendar: calendar)
        let expected = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: date)!)

        #expect(nextRefresh == expected)
    }
}
