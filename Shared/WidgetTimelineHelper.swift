//
//  WidgetTimelineHelper.swift
//  Daily AI Affirmations
//
//  Created by Codex.
//

import Foundation

struct WidgetTimelineHelper {
    static func nextRefreshDate(from date: Date, calendar: Calendar = .current) -> Date {
        let startOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: date) ?? date)
        return startOfTomorrow
    }
}
