//
//  AffirmationSelectorTests.swift
//  Daily AI AffirmationsTests
//
//  Created by Codex.
//

import Foundation
import Testing
@testable import Daily_AI_Affirmations

struct AffirmationSelectorTests {
    @Test func dailyIndexStartsAtZero() {
        let calendar = Calendar.gregorianUTC
        let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let index = AffirmationSelector.dailyIndex(for: date, count: 100, calendar: calendar)
        #expect(index == 0)
    }

    @Test func dailyIndexWrapsAtCount() {
        let calendar = Calendar.gregorianUTC
        let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 11))!
        let index = AffirmationSelector.dailyIndex(for: date, count: 10, calendar: calendar)
        #expect(index == 0)
    }

    @Test func languageDetectsSpanish() {
        let locale = Locale(identifier: "es_ES")
        #expect(AffirmationSelector.language(for: locale) == .spanish)
    }

    @Test func languageDefaultsToEnglish() {
        let locale = Locale(identifier: "fr_FR")
        #expect(AffirmationSelector.language(for: locale) == .english)
    }

    @Test func dailyAffirmationReturnsExpectedElement() {
        let calendar = Calendar.gregorianUTC
        let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let affirmation = AffirmationSelector.dailyAffirmation(for: date, language: .spanish, calendar: calendar)
        #expect(affirmation == AffirmationCatalog.spanish[0])
    }

    @Test func randomAffirmationIsFromCatalog() {
        let affirmation = AffirmationSelector.randomAffirmation(language: .english)
        #expect(AffirmationCatalog.english.contains(affirmation))
    }
}

private extension Calendar {
    static var gregorianUTC: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }
}
